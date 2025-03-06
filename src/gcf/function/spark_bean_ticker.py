from flask import Flask, jsonify
from datetime import datetime
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from pyspark.sql import SparkSession

app = Flask(__name__)

def run_beam_pipeline():
    """
    Starts an Apache Beam pipeline using the direct runner.
    
    The pipeline reads messages from a Google Cloud Pub/Sub subscription,
    processes each message through a custom ParDo to validate tickets, and writes valid tickets
    to an intermediate storage location.
    """
    options = PipelineOptions()
    with beam.Pipeline(options=options) as p:
        (p 
         | "ReadFromPubSub" >> beam.io.ReadFromPubSub(subscription="subscriptions/ticket-subscription")
         | "ValidateTickets" >> beam.ParDo(ValidateTicketDoFn())
         | "WriteToIntermediateStore" >> beam.io.WriteToText("path/to/intermediate/store")
        )

class ValidateTicketDoFn(beam.DoFn):
    """
    Beam DoFn for processing and validating ticket data.
    
    The expected input is a JSON string representation of a ticket,
    which is deserialized and validated based on UUID, seat number, date, and expiration time.
    """

    def process(self, element):
        """
        Process an individual ticket. Yields the ticket back if it's valid.
        
        :param element: JSON string of ticket data.
        """
        import json
        ticket = json.loads(element.decode('utf-8')) 
        if self.is_valid_ticket(ticket):
            yield element

    def is_valid_ticket(self, ticket):
        """
        Checks if the ticket data meets the validity criteria.
        
        :param ticket: Dictionary containing ticket attributes.
        :return: Boolean indicating ticket validity.
        """
        try:
            uuid = ticket['uuid']
            seat_number = int(ticket['seatNumber'])
            date = datetime.strptime(ticket['date'], '%Y-%m-%d')
            expire_time = datetime.strptime(ticket['expireTime'], '%Y-%m-%d %H:%M:%S')
            return datetime.now() < expire_time and datetime.now() < date and seat_number > 0
        except ValueError:
            return False

def run_spark_job():
    """
    Runs a PySpark job to process validated ticket data from intermediate storage.
    
    This function reads the text files, performs a simple aggregation, and shows the result.
    """
    spark = SparkSession.builder.appName("Process Valid Tickets").getOrCreate()
    df = spark.read.text("path/to/intermediate/store/*")
    processed_data = df.groupBy("someColumn").count()
    processed_data.show()
    spark.stop()

@app.route("/process-data", methods=['GET'])
def process_data():
    """
    Endpoint to trigger data processing through Apache Beam and Apache Spark.
    
    When this endpoint is accessed via a GET request, it initiates the Beam and Spark processing jobs.
    
    :return: JSON response indicating the initiation of data processing.
    """
    run_beam_pipeline()
    run_spark_job()
    return jsonify({"message": "Data processing initiated with Beam and processed by Spark. Check logs for details."})

if __name__ == '__main__':
    app.run(debug=True)
