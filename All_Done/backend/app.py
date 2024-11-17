import reflex as rx
from backend.api.tasks import TaskState

def main():
    app = rx.App()
    app.add_state(TaskState)
    app.compile()
