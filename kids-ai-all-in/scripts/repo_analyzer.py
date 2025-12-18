#!/usr/bin/env python3
"""
Komplette Repo-Analyse: Optimierungen, Verbesserungen, Entwickler-Zuordnung
"""

import os
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import json

PROJECT_ROOT = Path(__file__).parent.parent

class RepoAnalyzer:
    """Analysiert Repositories auf Optimierungsmöglichkeiten"""
    
    def __init__(self, repo_path: Path):
        self.repo_path = repo_path
        self.name = repo_path.name
        self.analysis = {
            'name': self.name,
            'timestamp': datetime.now().isoformat(),
            'optimizations': [],
            'improvements': [],
            'issues': [],
            'developer_assignments': {},
            'metrics': {}
        }
    
    def analyze(self) -> Dict:
        """Führt vollständige Analyse durch"""
        print(f"🔍 Analysiere {self.name}...")
        
        self._analyze_structure()
        self._analyze_code_quality()
        self._analyze_dependencies()
        self._analyze_performance()
        self._analyze_security()
        self._analyze_documentation()
        self._analyze_git_history()
        
        return self.analysis
    
    def _analyze_structure(self):
        """Analysiert Projektstruktur"""
        issues = []
        improvements = []
        
        # Prüfe auf Standard-Flutter-Struktur
        expected_dirs = ['lib', 'test', 'android', 'ios']
        missing_dirs = [d for d in expected_dirs if not (self.repo_path / d).exists()]
        
        if missing_dirs:
            issues.append({
                'type': 'structure',
                'severity': 'medium',
                'message': f'Fehlende Verzeichnisse: {", ".join(missing_dirs)}',
                'suggestion': 'Standard Flutter-Struktur implementieren'
            })
        
        # Prüfe auf große Dateien
        large_files = []
        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [d for d in dirs if d not in ['.git', 'build', 'node_modules']]
            for file in files:
                file_path = Path(root) / file
                try:
                    size = file_path.stat().st_size
                    if size > 1_000_000:  # > 1MB
                        large_files.append({
                            'file': str(file_path.relative_to(self.repo_path)),
                            'size_mb': round(size / 1_000_000, 2)
                        })
                except:
                    pass
        
        if large_files:
            improvements.append({
                'type': 'performance',
                'message': f'{len(large_files)} große Dateien gefunden',
                'files': large_files[:5],  # Nur erste 5
                'suggestion': 'Dateien komprimieren oder aufteilen'
            })
        
        self.analysis['issues'].extend(issues)
        self.analysis['improvements'].extend(improvements)
    
    def _analyze_code_quality(self):
        """Analysiert Code-Qualität"""
        improvements = []
        
        # Zähle Dart-Dateien
        dart_files = list(self.repo_path.rglob('*.dart'))
        total_lines = 0
        long_files = []
        
        for dart_file in dart_files:
            if 'build' in str(dart_file) or '.dart_tool' in str(dart_file):
                continue
            
            try:
                with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                    total_lines += len(lines)
                    
                    if len(lines) > 500:
                        long_files.append({
                            'file': str(dart_file.relative_to(self.repo_path)),
                            'lines': len(lines)
                        })
            except:
                pass
        
        self.analysis['metrics']['dart_files'] = len(dart_files)
        self.analysis['metrics']['total_lines'] = total_lines
        
        if long_files:
            improvements.append({
                'type': 'code_quality',
                'message': f'{len(long_files)} sehr lange Dateien (>500 Zeilen)',
                'files': long_files[:5],
                'suggestion': 'Dateien in kleinere Module aufteilen'
            })
        
        # Prüfe auf TODO/FIXME
        todos = []
        for dart_file in dart_files[:50]:  # Limit für Performance
            if 'build' in str(dart_file) or '.dart_tool' in str(dart_file):
                continue
            
            try:
                with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                    for i, line in enumerate(f, 1):
                        if 'TODO' in line or 'FIXME' in line:
                            todos.append({
                                'file': str(dart_file.relative_to(self.repo_path)),
                                'line': i,
                                'content': line.strip()[:100]
                            })
            except:
                pass
        
        if todos:
            improvements.append({
                'type': 'maintenance',
                'message': f'{len(todos)} TODO/FIXME Kommentare gefunden',
                'todos': todos[:10],
                'suggestion': 'Offene TODOs abarbeiten'
            })
        
        self.analysis['improvements'].extend(improvements)
    
    def _analyze_dependencies(self):
        """Analysiert Dependencies"""
        issues = []
        improvements = []
        
        pubspec = self.repo_path / 'pubspec.yaml'
        if pubspec.exists():
            try:
                with open(pubspec, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    # Prüfe auf veraltete Packages
                    if 'flutter:' in content:
                        # Prüfe Flutter-Version
                        if 'sdk: ">=' in content:
                            # Extrahiere Version (vereinfacht)
                            pass
                    
                    # Zähle Dependencies
                    deps_count = content.count('\n  ') - content.count('#')
                    self.analysis['metrics']['dependencies'] = deps_count
                    
                    if deps_count > 30:
                        improvements.append({
                            'type': 'dependencies',
                            'message': f'Viele Dependencies ({deps_count})',
                            'suggestion': 'Unbenutzte Dependencies entfernen'
                        })
            except:
                pass
        
        self.analysis['issues'].extend(issues)
        self.analysis['improvements'].extend(improvements)
    
    def _analyze_performance(self):
        """Analysiert Performance-Potenzial"""
        improvements = []
        
        # Prüfe auf große Assets
        assets_dir = self.repo_path / 'assets'
        if assets_dir.exists():
            total_size = 0
            for root, dirs, files in os.walk(assets_dir):
                for file in files:
                    file_path = Path(root) / file
                    try:
                        total_size += file_path.stat().st_size
                    except:
                        pass
            
            size_mb = total_size / 1_000_000
            self.analysis['metrics']['assets_size_mb'] = round(size_mb, 2)
            
            if size_mb > 50:
                improvements.append({
                    'type': 'performance',
                    'message': f'Große Assets ({round(size_mb, 2)} MB)',
                    'suggestion': 'Assets komprimieren oder lazy loading implementieren'
                })
        
        self.analysis['improvements'].extend(improvements)
    
    def _analyze_security(self):
        """Analysiert Sicherheitsaspekte"""
        issues = []
        
        # Prüfe auf API Keys
        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [d for d in dirs if d not in ['.git', 'build', 'node_modules']]
            
            for file in files:
                if not any(file.endswith(ext) for ext in ['.dart', '.js', '.py', '.ts']):
                    continue
                
                file_path = Path(root) / file
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        
                        # Prüfe auf hardcoded Keys
                        if 'AIza' in content or 'sk-' in content:
                            if 'process.env' not in content and 'os.getenv' not in content:
                                issues.append({
                                    'type': 'security',
                                    'severity': 'critical',
                                    'file': str(file_path.relative_to(self.repo_path)),
                                    'message': 'Möglicher hardcoded API Key',
                                    'suggestion': 'API Key in Environment Variable verschieben'
                                })
                except:
                    pass
        
        self.analysis['issues'].extend(issues)
    
    def _analyze_documentation(self):
        """Analysiert Dokumentation"""
        improvements = []
        
        readme = self.repo_path / 'README.md'
        has_readme = readme.exists()
        
        # Prüfe auf Dokumentationsdateien
        doc_files = list(self.repo_path.glob('*.md'))
        self.analysis['metrics']['documentation_files'] = len(doc_files)
        
        if not has_readme:
            improvements.append({
                'type': 'documentation',
                'message': 'Kein README.md gefunden',
                'suggestion': 'README.md mit Projektbeschreibung erstellen'
            })
        
        self.analysis['improvements'].extend(improvements)
    
    def _analyze_git_history(self):
        """Analysiert Git-Historie für Entwickler-Zuordnung"""
        developers = {}
        
        try:
            # Git log für Entwickler-Statistiken
            result = subprocess.run(
                ['git', 'log', '--pretty=format:%an|%ae', '--all'],
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                for line in result.stdout.strip().split('\n'):
                    if '|' in line:
                        name, email = line.split('|', 1)
                        if name not in developers:
                            developers[name] = {
                                'email': email,
                                'commits': 0,
                                'files_touched': set()
                            }
                        developers[name]['commits'] += 1
                
                # Files touched
                result = subprocess.run(
                    ['git', 'log', '--pretty=format:%an', '--name-only', '--all'],
                    cwd=self.repo_path,
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if result.returncode == 0:
                    current_dev = None
                    for line in result.stdout.strip().split('\n'):
                        if line.strip() and '|' not in line:
                            if line.endswith('.dart') or line.endswith('.js'):
                                if current_dev and current_dev in developers:
                                    developers[current_dev]['files_touched'].add(line.strip())
                            else:
                                current_dev = line.strip()
                
                # Convert sets to counts
                for dev in developers:
                    developers[dev]['files_count'] = len(developers[dev]['files_touched'])
                    developers[dev]['files_touched'] = list(developers[dev]['files_touched'])[:10]  # Limit
        
        except Exception as e:
            print(f"⚠️ Fehler bei Git-Analyse: {e}")
        
        self.analysis['developer_assignments'] = developers
    
    def generate_report(self) -> str:
        """Generiert Text-Report"""
        report = f"\n{'='*80}\n"
        report += f"📊 REPO-ANALYSE: {self.name}\n"
        report += f"{'='*80}\n\n"
        
        # Metrics
        if self.analysis['metrics']:
            report += "📈 METRIKEN:\n"
            report += "-" * 80 + "\n"
            for key, value in self.analysis['metrics'].items():
                report += f"  • {key}: {value}\n"
            report += "\n"
        
        # Issues
        if self.analysis['issues']:
            report += "🔴 ISSUES:\n"
            report += "-" * 80 + "\n"
            for issue in self.analysis['issues']:
                report += f"  [{issue.get('severity', 'unknown').upper()}] {issue.get('message', '')}\n"
                if 'file' in issue:
                    report += f"    Datei: {issue['file']}\n"
                if 'suggestion' in issue:
                    report += f"    Vorschlag: {issue['suggestion']}\n"
            report += "\n"
        
        # Improvements
        if self.analysis['improvements']:
            report += "💡 VERBESSERUNGEN:\n"
            report += "-" * 80 + "\n"
            for imp in self.analysis['improvements']:
                report += f"  • {imp.get('message', '')}\n"
                if 'suggestion' in imp:
                    report += f"    Vorschlag: {imp['suggestion']}\n"
            report += "\n"
        
        # Developers
        if self.analysis['developer_assignments']:
            report += "👥 ENTWICKLER:\n"
            report += "-" * 80 + "\n"
            for dev, stats in self.analysis['developer_assignments'].items():
                report += f"  • {dev} ({stats.get('email', 'N/A')})\n"
                report += f"    Commits: {stats.get('commits', 0)}, Dateien: {stats.get('files_count', 0)}\n"
            report += "\n"
        
        report += "="*80 + "\n"
        
        return report


def analyze_all_repos():
    """Analysiert alle Repositories"""
    apps_dir = PROJECT_ROOT / 'apps'
    
    if not apps_dir.exists():
        print("❌ apps/ Verzeichnis nicht gefunden!")
        return
    
    all_analyses = {}
    
    for app_dir in apps_dir.iterdir():
        if app_dir.is_dir() and (app_dir / '.git').exists():
            analyzer = RepoAnalyzer(app_dir)
            analysis = analyzer.analyze()
            all_analyses[app_dir.name] = analysis
            
            # Print Report
            print(analyzer.generate_report())
    
    # Speichere Gesamtanalyse
    output_file = PROJECT_ROOT / 'repo_analysis_complete.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_analyses, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Vollständige Analyse gespeichert: {output_file}")


if __name__ == '__main__':
    analyze_all_repos()

