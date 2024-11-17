from backend.db.database import SessionLocal, Task

# Créer une nouvelle tâche
def create_task(title: str, description: str = ""):
    db = SessionLocal()
    new_task = Task(title=title, description=description)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    db.close()
    return new_task

# Récupérer toutes les tâches
def get_tasks():
    db = SessionLocal()
    tasks = db.query(Task).all()
    db.close()
    return tasks

# Mettre à jour le statut d'une tâche
def update_task_status(task_id: int, new_status: str):
    db = SessionLocal()
    task = db.query(Task).filter(Task.id == task_id).first()
    if task:
        task.status = new_status
        db.commit()
    db.close()
    return task
