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

def process_data(task_number):
    print(f"Processing task {task_number} on Celery worker")
    return f"Task {task_number} completed"

with DAG(
    'example_celery_executor',
    default_args=default_args,
    description='Example DAG for CeleryExecutor with parallel tasks',
    schedule=timedelta(days=1),
    catchup=False,
) as dag:

    tasks = []
    for i in range(5):
        task = PythonOperator(
            task_id=f'process_task_{i}',
            python_callable=process_data,
            op_kwargs={'task_number': i},
        )
        tasks.append(task)
