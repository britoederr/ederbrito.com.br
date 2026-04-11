import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL ?? "info",
  // Structured fields attached to every log line
  base: {
    service: "ederbrito-frontend",
    env: process.env.NODE_ENV ?? "development",
  },
  // ISO timestamp for Loki label parsing
  timestamp: pino.stdTimeFunctions.isoTime,
});
