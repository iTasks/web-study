#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { StepfunctionsRestApiStack } from '../lib/stepfunctions-rest-api-stack';

const app = new cdk.App();
new StepfunctionsRestApiStack(app, 'CDKStepfunctionsRestApiStack');
