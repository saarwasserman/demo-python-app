import logging

from fastapi import FastAPI
import structlog

logging.basicConfig(level=logging.INFO, format="%(message)s")

# Structlog config
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),             # ISO timestamp
        structlog.stdlib.add_log_level,                          # Add log level
        structlog.stdlib.PositionalArgumentsFormatter(),         # Format args
        structlog.processors.StackInfoRenderer(),                # Stack info if needed
        structlog.processors.format_exc_info,                    # Exceptions
        structlog.processors.JSONRenderer()                      # Output as JSON
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory()
)

log = structlog.get_logger()


app = FastAPI()

@app.get("/")
async def root():
    log.info("user visited", user_id="12345", request_id="abc-123")
    return {"message": "Hello Python"}
