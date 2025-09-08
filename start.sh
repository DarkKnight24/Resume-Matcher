#!/bin/bash

set -e

# Function to cleanup background processes
cleanup() {
    echo "Stopping services..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
    fi
    # Wait for processes to terminate
    wait $BACKEND_PID 2>/dev/null
    wait $FRONTEND_PID 2>/dev/null
    echo "Services stopped."
}

# Trap signals and call cleanup
trap cleanup SIGTERM SIGINT

# Start backend
cd apps/backend
echo "Starting backend on port 8000..."
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ../..

# Start frontend
cd apps/frontend
echo "Starting frontend on port 3000..."
npm start &
FRONTEND_PID=$!
cd ../..

# Wait for all background processes
# If one process exits, the script will continue to wait for the other
# or exit if both are gone.
echo "Services started. Waiting for signals..."
wait $BACKEND_PID
echo "Backend service exited."
wait $FRONTEND_PID
echo "Frontend service exited."