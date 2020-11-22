Go to your bucket and unblock all public access

Go to the policy editor and allow public access

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow", 
            "Principal": "*", 
            "Action": "s3:GetObject", 
            "Resource": "arn:aws:s3:::[YOUR_BUCKET_NAME]/*" 
        } 
    ] 
}
```

Enable web site hosting

1. From the bucket detail page in the S3 console, choose the Properties tab.
1. Choose the Static website hosting card.
1. Select Use this bucket to host a website and enter index.html for the Index document. Leave the other fields blank.
1. Note the Endpoint URL at the top of the dialog before choosing Save. You will use this URL throughout the rest of the workshop to view your web application. From here on this URL will be referred to as your website's base URL.
1. Click Save to save your changes.


Optional Set up a redirect rule

Any invalid traffic will go to the root of the site to index.html

```xml
<RoutingRules>
    <RoutingRule>
        <Condition>
            <HttpErrorCodeReturnedEquals>404</HttpErrorCodeReturnedEquals>
        </Condition>
        <Redirect>            
            <ReplaceKeyWith>index.html</ReplaceKeyWith>
        </Redirect>
    </RoutingRule>
</RoutingRules>
```