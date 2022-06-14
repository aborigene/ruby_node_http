#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
# Require otel-ruby
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

# Export traces to console by default
#ENV['OTEL_TRACES_EXPORTER'] ||= 'console'

# configure SDK with defaults
OpenTelemetry::SDK.configure
# Configure the sdk with custom export
  OpenTelemetry::SDK.configure do |c|
    c.service_name="greeter client"
    c.use_all()
    for name in ["dt_metadata_e617c525669e072eebe3d0f08212e8f2.properties", "/var/lib/dynatrace/enrichment/dt_metadata.properties"] do
      begin
        c.resource = OpenTelemetry::SDK::Resources::Resource.create(Hash[*File.read(name.start_with?("/var") ? name : File.read(name)).split(/[=\n]+/)])
      rescue
      end
    end
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new(
          #endpoint: 'http://localhost:14499/otlp/v1/traces'
          endpoint: 'https://xxxx.live.dynatrace.com/api/v2/otlp/v1/traces',
          #endpoint: 'http://localhost:55680'
          headers: {'Authorization' => 'Api-Token ' + ENV["DT_API_TOKEN"]}
        )
      )
    )
  #rescue
  #  puts "#{$!.class.name}: #{$!}", *$!.backtrace
  #  raise
  end
# Rack middleware to extract span context, create child span, and add
# attributes/events to the span
class OpenTelemetryMiddleware
  def initialize(app)
    @app = app
    @tracer = OpenTelemetry.tracer_provider.tracer('sinatra', '1.0')
  end

  def call(env)
    # Extract context from request headers
    context = OpenTelemetry.propagation.extract(
      env,
      getter: OpenTelemetry::Context::Propagation.rack_env_getter
    )

    status, headers, response_body = 200, {}, ''

    # Span name SHOULD be set to route:
    span_name = env['PATH_INFO']

    # For attribute naming, see
    # https://github.com/open-telemetry/opentelemetry-specification/blob/master/specification/data-semantic-conventions.md#http-server

    # Activate the extracted context
    OpenTelemetry::Context.with_current(context) do
      # Span kind MUST be `:server` for a HTTP server span
      @tracer.in_span(
        span_name,
        attributes: {
          'component' => 'http',
          'http.method' => env['REQUEST_METHOD'],
          'http.route' => env['PATH_INFO'],
          'http.url' => env['REQUEST_URI'],
        },
        kind: :server
      ) do |span|
        # Run application stack
        status, headers, response_body = @app.call(env)

        span.set_attribute('http.status_code', status)
      end
    end

    [status, headers, response_body]
  end
end

class App < Sinatra::Base
  set :bind, '0.0.0.0'
  use OpenTelemetryMiddleware

  get '/hello' do
    puts 'Hello World!'
  end

  run! if app_file == $0
end
