#!/usr/bin/env bash
# Script para configurar la facturación y crear/vincular el proyecto de Google Cloud
cd ~/agent-valley-nightmarket
if [ -n "$AGENT_VALLEY_REUSE_PROJECT" ]; then
  echo "Reusing existing project..."
else
  echo "Creating new Agent Valley project..."
fi
# Lógica para registrar el project_id en ~/project_id.txt