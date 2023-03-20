import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket='gel-platform-2tpjz5pxb9dv-bucket-a')
    logging.info(event)
    e = event.get('Records')[0].get('s3').get('object')
    return {
        'event' : e
    }
