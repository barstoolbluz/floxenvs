from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'example_kubernetes_pod',
    default_args=default_args,
    description='Example DAG using KubernetesPodOperator',
    schedule=timedelta(days=1),
    catchup=False,
) as dag:

    k8s_task = KubernetesPodOperator(
        task_id='run_python_in_pod',
        name='airflow-test-pod',
        namespace='default',
        image='python:3.11-slim',
        cmds=['python', '-c'],
        arguments=['print("Hello from Kubernetes Pod!")'],
        is_delete_operator_pod=True,
        get_logs=True,
    )
