import reflex as rx
from backend.api.tasks import TaskState

def task_page():
    return rx.Box(
        children=[
            rx.Text("Liste des tâches"),
            rx.Input(placeholder="Titre de la tâche", id="title"),
            rx.Button("Ajouter", on_click=rx.task(TaskState.add_task, "title")),
            rx.UnorderedList(
                rx.foreach(
                    TaskState.tasks,
                    lambda task: rx.Text(f"{task.title} - {task.status}"),
                )
            ),
        ]
    )

def main():
    app = rx.App()
    app.add_state(TaskState)
    app.add_page(task_page, route="/tasks")
    app.compile()
