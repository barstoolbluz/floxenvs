from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def print_hello():
    print("Hello from LocalExecutor!")
    return "Task completed"

with DAG(
    'example_local_executor',
    default_args=default_args,
    description='Example DAG for LocalExecutor',
    schedule=timedelta(days=1),
    catchup=False,
) as dag:

    task = PythonOperator(
        task_id='print_hello',
        python_callable=print_hello,
    )
