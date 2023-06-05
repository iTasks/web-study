package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.LambdaLogger

public class TestContext implements Context{
  public TestContext() {}
  public String getAwsRequestId(){
    return new String("495b12a8-xmpl-4eca-8168-160484189f99");// aws instance id
  }
  public String getLogGroupName(){
    return new String("/aws/lambda/my-function");
  }
  ...
  public LambdaLogger getLogger(){
    return new TestLogger();
  }

}
