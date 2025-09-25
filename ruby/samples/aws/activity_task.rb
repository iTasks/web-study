
 require_relative '../lib/step_functions/activity'
 credentials = Aws::SharedCredentials.new
 region = 'us-west-2'
 activity_arn = 'ACTIVITY_ARN'
 
 activity = StepFunctions::Activity.new(
   credentials: credentials,
   region: region,
   activity_arn: activity_arn,
   workers_count: 1,
   pollers_count: 1,
   heartbeat_delay: 30
 )
 
 # The start method takes as argument the block that is the actual logic of your custom activity.
 activity.start do |input|
   { result: :SUCCESS, echo: input['value'] }                    
 end
