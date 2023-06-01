import * as cdk from 'aws-cdk-lib';
import * as stepfunctions from 'aws-cdk-lib/aws-stepfunctions';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

export class StepfunctionsRestApiStack extends cdk.Stack {
    constructor(app: cdk.App, id: string) {
      super(app, id);

      const startState = new stepfunctions.Pass(this, 'PassState', {
          result: { value:'Hello back to you!' },
      })

      const stateMachine = new stepfunctions.StateMachine(this, 'CDKStateMachine', {
          definition: startState,
          stateMachineType: stepfunctions.StateMachineType.EXPRESS,
      });

      const api = new apigateway.StepFunctionsRestApi(this, 'CDKStepFunctionsRestApi', { stateMachine: stateMachine });
    }
}
