import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    result = 'Hello, world!'
    logger.info('', result)
    response = {'result': result}
    return response
