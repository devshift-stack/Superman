#!/usr/bin/env python3
"""
Generiert Dashboard-Daten mit echten Repository-Informationen
"""

import os
import json
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict

PROJECT_ROOT = Path(__file__).parent.parent
DASHBOARD_DATA_FILE = PROJECT_ROOT / 'dashboard_data.json'

def get_git_info(repo_path: Path) -> Dict:
    """Holt Git-Informationen für ein Repository"""
    info = {
        'name': repo_path.name,
        'branch': None,
        'last_commit': None,
        'commits_today': 0,
        'commits_week': 0,
        'status': 'unknown'
    }
    
    try:
        # Branch
        result = subprocess.run(
            ['git', 'branch', '--show-current'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info['branch'] = result.stdout.strip()
        
        # Last commit
        result = subprocess.run(
            ['git', 'log', '-1', '--format=%H|%an|%s|%cd', '--date=iso'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout.strip():
            parts = result.stdout.strip().split('|')
            if len(parts) >= 4:
                info['last_commit'] = {
                    'hash': parts[0][:8],
                    'author': parts[1],
                    'message': parts[2][:50],
                    'date': parts[3]
                }
        
        # Commits today
        result = subprocess.run(
            ['git', 'log', '--since=midnight', '--oneline'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info['commits_today'] = len([l for l in result.stdout.strip().split('\n') if l])
        
        # Commits week
        result = subprocess.run(
            ['git', 'log', '--since=7 days ago', '--oneline'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info['commits_week'] = len([l for l in result.stdout.strip().split('\n') if l])
        
        # Status
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info['status'] = 'modified' if result.stdout.strip() else 'clean'
    
    except Exception as e:
        info['error'] = str(e)
    
    return info

def get_developers() -> Dict:
    """Holt Entwickler-Statistiken"""
    devs = {}
    
    try:
        # Prüfe ob Hauptverzeichnis Git-Repo ist
        result = subprocess.run(
            ['git', 'rev-parse', '--git-dir'],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode == 0:
            # Hauptverzeichnis ist Git-Repo
            result = subprocess.run(
                ['git', 'shortlog', '-sn', '--all'],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                for line in result.stdout.strip().split('\n'):
                    if line.strip():
                        parts = line.split('\t')
                        if len(parts) == 2:
                            commits = int(parts[0].strip())
                            name = parts[1].strip()
                            devs[name] = {
                                'commits': commits,
                                'files_changed': 0
                            }
            
            # Files changed
            result = subprocess.run(
                ['git', 'log', '--all', '--pretty=format:%an', '--numstat'],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                current_dev = None
                for line in lines:
                    if '\t' not in line and line.strip():
                        current_dev = line.strip()
                    elif '\t' in line and current_dev and current_dev in devs:
                        parts = line.split('\t')
                        if len(parts) >= 3:
                            try:
                                additions = int(parts[0]) if parts[0] != '-' else 0
                                deletions = int(parts[1]) if parts[1] != '-' else 0
                                devs[current_dev]['files_changed'] += additions + deletions
                            except:
                                pass
        else:
            # Suche in Unterverzeichnissen
            for item in PROJECT_ROOT.iterdir():
                if item.is_dir() and (item / '.git').exists():
                    try:
                        result = subprocess.run(
                            ['git', 'shortlog', '-sn', '--all'],
                            cwd=item,
                            capture_output=True,
                            text=True,
                            timeout=5
                        )
                        if result.returncode == 0:
                            for line in result.stdout.strip().split('\n'):
                                if line.strip():
                                    parts = line.split('\t')
                                    if len(parts) == 2:
                                        commits = int(parts[0].strip())
                                        name = parts[1].strip()
                                        if name not in devs:
                                            devs[name] = {'commits': 0, 'files_changed': 0}
                                        devs[name]['commits'] += commits
                    except:
                        pass
    
    except Exception as e:
        print(f"⚠️ Fehler bei Entwickler-Statistiken: {e}")
    
    return devs

def check_security() -> Dict:
    """Einfache Sicherheitsprüfung"""
    issues = {'critical': [], 'warnings': []}
    
    # Prüfe auf API Keys in Code
    for root, dirs, files in os.walk(PROJECT_ROOT):
        dirs[:] = [d for d in dirs if d not in ['.git', 'build', 'node_modules', '.dart_tool', 'scripts']]
        
        for file in files:
            if not any(file.endswith(ext) for ext in ['.dart', '.js', '.py', '.ts']):
                continue
            
            file_path = Path(root) / file
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                    if 'AIza' in content or 'sk-' in content:
                        if 'process.env' not in content and 'os.getenv' not in content:
                            issues['critical'].append({
                                'file': str(file_path.relative_to(PROJECT_ROOT)),
                                'issue': 'Möglicher hardcoded API Key'
                            })
            except:
                pass
    
    return {
        'overall': 'critical' if issues['critical'] else 'good',
        'critical_count': len(issues['critical']),
        'warnings_count': len(issues['warnings']),
        'issues': issues
    }

def generate_dashboard():
    """Generiert vollständiges Dashboard"""
    print("🔍 Generiere Dashboard-Daten...")
    
    dashboard = {
        'timestamp': datetime.now().isoformat(),
        'repos': {},
        'security': {},
        'developers': {},
        'summary': {}
    }
    
    # Finde Repositories
    repos_found = []
    
    # Prüfe Hauptverzeichnis
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--git-dir'],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            repos_found.append(PROJECT_ROOT)
            print(f"  📦 Hauptverzeichnis ist Git-Repo")
    except:
        pass
    
    # Suche in Unterverzeichnissen
    for item in PROJECT_ROOT.iterdir():
        if item.is_dir() and (item / '.git').exists():
            repos_found.append(item)
    
    # Analysiere Repos
    for repo_path in repos_found:
        print(f"  📦 Analysiere {repo_path.name}...")
        repo_info = get_git_info(repo_path)
        dashboard['repos'][repo_path.name] = repo_info
    
    # Entwickler
    print("  👥 Analysiere Entwickler...")
    dashboard['developers'] = get_developers()
    
    # Sicherheit
    print("  🔒 Prüfe Sicherheit...")
    dashboard['security'] = check_security()
    
    # Summary
    total_repos = len(dashboard['repos'])
    active_repos = sum(1 for r in dashboard['repos'].values() if r.get('commits_today', 0) > 0)
    total_commits = sum(r.get('commits_week', 0) for r in dashboard['repos'].values())
    
    dashboard['summary'] = {
        'total_repos': total_repos,
        'active_repos': active_repos,
        'total_commits_week': total_commits,
        'security_status': dashboard['security']['overall'],
        'total_developers': len(dashboard['developers'])
    }
    
    # Speichere
    with open(DASHBOARD_DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(dashboard, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Dashboard-Daten gespeichert: {DASHBOARD_DATA_FILE}")
    print(f"   📦 Repos: {total_repos}")
    print(f"   👥 Entwickler: {len(dashboard['developers'])}")
    print(f"   🔒 Sicherheit: {dashboard['security']['overall']}")
    
    return dashboard

if __name__ == '__main__':
    generate_dashboard()
