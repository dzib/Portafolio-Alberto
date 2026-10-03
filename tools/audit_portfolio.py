## Versión 1.3.0

# - Mejora en la detección de enlaces rotos.
# - Actualización de la lógica para resolver rutas relativas.

import os
import re

def audit_and_fix_links(auto_fix=True):
    print(f"[INFO] Iniciando auditoría con rastreo global de archivos (Modo Auto-Fix: {auto_fix})...")
    broken_links_count = 0
    fixed_links_count = 0

    root_dir = "."

    # Construir un índice global de todos los archivos disponibles en el proyecto (especialmente en 00.assets)
    file_index = {}
    for subdir, dirs, files in os.walk(root_dir):
        if '.git' in subdir or 'venv' in subdir or 'node_modules' in subdir:
            continue
        for file in files:
            file_index[file] = os.path.relpath(os.path.join(subdir, file), root_dir).replace("\\", "/")

    for subdir, dirs, files in os.walk(root_dir):
        if '.git' in subdir or 'venv' in subdir or 'node_modules' in subdir:
            continue

        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(subdir, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                original_content = content

                # Buscar enlaces en formato Markdown
                links = re.findall(r'\[(.*?)\]\((.*?)\)', content)
                for text, link in links:
                    # Ignorar enlaces web externos, correos o anclas puras
                    if link.startswith(("http", "https", "mailto", "#")):
                        continue

                    clean_link = link.split('#')[0]
                    if not clean_link:
                        continue

                    # Validar si la ruta actual existe físicamente desde el subdirectorio
                    target_path = os.path.normpath(os.path.join(subdir, clean_link))
                    if not os.path.exists(target_path):
                        # Buscar si el archivo existe en otra parte del proyecto (ej. en 00.assets)
                        filename = os.path.basename(clean_link)
                        if filename in file_index:
                            # Calcular la ruta relativa correcta desde el archivo .md actual hasta el archivo encontrado
                            absolute_target = os.path.join(root_dir, file_index[filename])
                            relative_to_md = os.path.relpath(absolute_target, subdir).replace("\\", "/")

                            # Asegurar formato de ruta relativa estándar con ./ si es necesario o directo
                            if not relative_to_md.startswith("../"):
                                relative_to_md = "./" + relative_to_md

                            if auto_fix:
                                content = content.replace(f"]({link})", f"]({relative_to_md})")
                                print(f"[CORREGIDO] En {file_path}: {link} -> {relative_to_md}")
                                fixed_links_count += 1
                        else:
                            print(f"[ENLACE ROTO CRÍTICO] En {file_path} -> No se encuentra el archivo: {filename}")
                            broken_links_count += 1

                if auto_fix and content != original_content:
                    with open(file_path, "w", encoding="utf-8") as f:
                        f.write(content)

    print(f"\n[RESUMEN] Enlaces rotos restantes: {broken_links_count} | Enlaces corregidos: {fixed_links_count}")
    if broken_links_count == 0:
        print("[ÉXITO] ¡Portafolio 100% íntegro y sin enlaces rotos!")

if __name__ == "__main__":
    audit_and_fix_links(auto_fix=True)
