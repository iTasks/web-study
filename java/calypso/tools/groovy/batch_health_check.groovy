#!/usr/bin/env groovy

import groovy.json.JsonOutput

def argsMap = [:]
for (int i = 0; i < this.args.length - 1; i += 2) {
    argsMap[this.args[i]] = this.args[i + 1]
}

def inputPath = argsMap['--input']
def slaMs = (argsMap['--sla-ms'] ?: '1000') as long

if (!inputPath) {
    println 'Usage: groovy batch_health_check.groovy --input batch.csv [--sla-ms 1000]'
    System.exit(1)
}

def lines = new File(inputPath).readLines().findAll { it?.trim() }
if (lines.size() < 2) {
    println JsonOutput.prettyPrint(JsonOutput.toJson([jobs: 0, breaches: 0, message: 'No data rows found']))
    System.exit(0)
}

// Expected CSV: job_name,duration_ms,status

def breaches = []
def jobs = 0
lines.drop(1).each { line ->
    def cols = line.split(',')*.trim()
    if (cols.size() >= 3) {
        jobs++
        def duration = cols[1] as long
        def status = cols[2]
        if (duration > slaMs || !status.equalsIgnoreCase('SUCCESS')) {
            breaches << [job: cols[0], durationMs: duration, status: status]
        }
    }
}

def report = [
    jobs: jobs,
    slaMs: slaMs,
    breaches: breaches.size(),
    details: breaches
]

println JsonOutput.prettyPrint(JsonOutput.toJson(report))
