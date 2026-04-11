import { NextResponse } from "next/server";
import client from "prom-client";

// Use a global registry so metrics survive hot-reloads in dev
const globalForMetrics = global as typeof global & {
  metricsRegistry?: client.Registry;
  pageViewsTotal?: client.Counter;
  httpRequestDuration?: client.Histogram;
};

if (!globalForMetrics.metricsRegistry) {
  const register = new client.Registry();
  register.setDefaultLabels({ service: "ederbrito-frontend" });

  client.collectDefaultMetrics({ register, prefix: "nextjs_" });

  globalForMetrics.pageViewsTotal = new client.Counter({
    name: "nextjs_page_views_total",
    help: "Total number of page views by path",
    labelNames: ["path"],
    registers: [register],
  });

  globalForMetrics.httpRequestDuration = new client.Histogram({
    name: "nextjs_http_request_duration_seconds",
    help: "Duration of HTTP requests in seconds",
    labelNames: ["method", "route", "status_code"],
    buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
    registers: [register],
  });

  globalForMetrics.metricsRegistry = register;
}

export const metricsRegistry = globalForMetrics.metricsRegistry!;
export const pageViewsTotal = globalForMetrics.pageViewsTotal!;
export const httpRequestDuration = globalForMetrics.httpRequestDuration!;

export async function GET() {
  return new NextResponse(await metricsRegistry.metrics(), {
    headers: { "Content-Type": metricsRegistry.contentType },
  });
}
