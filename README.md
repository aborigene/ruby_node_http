# Dynatrace OpenTelemetry Ruby Example

## HTTP

This is a simple example that demonstrates tracing an HTTP request from NodeJS to Ruby server. The example shows several aspects of tracing, such as:


* Using the `TracerProvider`
* Span Attributes
* Using the console exporter
* How to export to Dynatrace

### Running on Kubernetes

To test otel and trace enrichment on Kubertes + Dynatrace, just:

1. Change the code to point to your environment
2. Build the image: `docker build . -t <image tag>`
3. Push the image to repo: `docker push <image tag>`
4. Change the ruby_service.yaml to add your token and image
5. Deploy the example: `kubectl apply -f ruby_service.yaml`

This will expose the service on a public port 4567 and you be able to test with curl:

`curl <public ip from the created service>:4567/hello`

This will return a simple 200 OK and traces will be sent do Dynatrace, enriched with metada collected by the OneAgent. These traces then will not incur in DDU consumptiom because the host is already being monitored by OneAgent in FullStack mode.


### Running the example

This is the procedure to execute locally outside of a Kubernetes.

1. Install gems
  * `bundle install`
1. Run the service_up.sh script to bring everything up (Node + Ruby)
	* `./service_up.sh`
1. In a separate terminal window, run cur against NodeJS:
	* `curl 127.0.0.1:3000`

### Stopping the example
 service_deploy.sh  service_down.sh  service_up.sh
1. Run the service_down.sh script to bring everything down (Node + Ruby)
	* `./service_down.sh`

### Simulating a deploy

1. Install gems
  * `bundle install`
1. Run the service_deploy.sh script to stop and start everything (Node + Ruby). This will also send a DEPLOYMENT event to Dynatrace
	* `./service_deploy.sh`
1. Please leave curl running during the deploy simulation, application has some logic to become slow on restart
1. Tag the services like this:
  * Node: lab_node
  * Ruby:  ruby_server 
1. Leave it running for some time (at least 2hs) and then simulate the deploy. Dynatrace will:\
  * Add the event to right services
  * Create a slowdown problem card
  * IA will use the event as part of its analysis and show the root cause after sometime

### Configuration necessary

1. Cluster URL
  * On Ruby files to proper configure the OTEL exporter
  * On service_deploy.sh, so Deploy event can be sent to cluster
1. API Tokens 
  * On Ruby files it should be a token with permissions for trace ingestion
  * On Shell files it should be a token with permissions to send events to Dynatrace (Access problem and event feed, metrics, and topology

### Sending load

1. On a different terminal run curl.sh command
  * This will create and endless loop calling the 127.0.0.1:3000 endpoint
