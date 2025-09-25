import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import uuid
from datetime import datetime, timedelta

class ValidateTicket(beam.DoFn):
    def process(self, element):
        # Example ticket format: UUID,CustomerNumber,DrawDate,PurchaseDate,PrizeCollectionDate
        ticket_data = element.split(',')
        if len(ticket_data[1]) == 6 and ticket_data[1].isdigit():
            yield element

def calculate_prize_collection_date(draw_date_str):
    draw_date = datetime.strptime(draw_date_str, '%Y-%m-%d')
    return (draw_date + timedelta(days=30)).strftime('%Y-%m-%d')

pipeline_options = PipelineOptions(runner='SparkRunner', project='your-gcp-project')
with beam.Pipeline(options=pipeline_options) as p:
    tickets = (
        p
        | 'Read Tickets' >> beam.io.ReadFromPubSub(subscription='projects/your-gcp-project/subscriptions/tickets-subscription')
        | 'Validate Tickets' >> beam.ParDo(ValidateTicket())
        | 'Generate UUIDs' >> beam.Map(lambda x: str(uuid.uuid4()) + ',' + x)
        | 'Calculate Prize Collection Dates' >> beam.Map(lambda x: x + ',' + calculate_prize_collection_date(x.split(',')[2]))
        | 'Write to Storage' >> beam.io.WriteToBigQuery(
            table='your_project:your_dataset.tickets',
            schema='UUID:STRING, CustomerNumber:STRING, DrawDate:DATE, PurchaseDate:DATE, PrizeCollectionDate:DATE',
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND)
    )
