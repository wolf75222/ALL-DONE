#!/bin/bash

# Nom du projet
PROJECT_NAME="All_Done"

# Création des dossiers
echo "📁 Création de la structure de l'application..."
mkdir -p $PROJECT_NAME/{backend/{api,models,db},frontend/{components,styles},migrations,tests,docker}

# Fichiers principaux
echo "📄 Création des fichiers principaux..."
touch $PROJECT_NAME/{README.md,requirements.txt,reflex_config.py}
touch $PROJECT_NAME/backend/{app.py,__init__.py}
touch $PROJECT_NAME/frontend/{app.py,__init__.py}
touch $PROJECT_NAME/docker/{Dockerfile,docker-compose.yml}

# Backend : fichiers de base
echo "📄 Ajout des fichiers Backend..."
cat <<EOF > $PROJECT_NAME/backend/app.py
import reflex as rx
from backend.api.tasks import TaskState

def main():
    app = rx.App()
    app.add_state(TaskState)
    app.compile()
EOF

mkdir -p $PROJECT_NAME/backend/api
cat <<EOF > $PROJECT_NAME/backend/api/tasks.py
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
EOF

mkdir -p $PROJECT_NAME/backend/db
cat <<EOF > $PROJECT_NAME/backend/db/database.py
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Configuration de la base SQLite
DATABASE_URL = "sqlite:///all_done.db"

engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Modèle de table : Tâche
class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String)
    status = Column(String, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)

# Initialisation de la base
def init_db():
    Base.metadata.create_all(bind=engine)
EOF

# Frontend : fichiers de base
echo "📄 Ajout des fichiers Frontend..."
cat <<EOF > $PROJECT_NAME/frontend/app.py
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
EOF

# Docker : fichiers de configuration
echo "📄 Configuration de Docker..."
cat <<EOF > $PROJECT_NAME/docker/Dockerfile
FROM python:3.11-slim

# Installer les dépendances
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

# Commande par défaut
CMD ["python", "backend/app.py"]
EOF

cat <<EOF > $PROJECT_NAME/docker/docker-compose.yml
version: "3.9"
services:
  web:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: all_done
    ports:
      - "5432:5432"
EOF

# Requirements : dépendances Python
echo "📄 Ajout des dépendances dans requirements.txt..."
cat <<EOF > $PROJECT_NAME/requirements.txt
reflex
sqlalchemy
EOF

# Finalisation
echo "✨ Structure complète créée dans le dossier '$PROJECT_NAME'."
echo "👉 Lancez 'python -c \"from backend.db.database import init_db; init_db()\"' pour initialiser la base SQLite."

