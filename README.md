# BDA Remote

A remote competition management API for BDArmory. BDA is a combat AI mod for the popular game Kerbal Space Program.

This API offers the following basic objects:

* Competitions - Top level grouping collects all data for a given tournament.

* Players - Top level collection of people participating in any competition.

* Vessels - For each competition, each player may submit zero or one vessel.

* Heats - Craft are organized into brackets, initially randomized, and subsequently organized based on progressive performance through a series of heats.

* Records - Results describing the performance of each vessel in each heat.

# Aggregation API (write-only)

## POST /records/batch.json
{"records": [{...}]}
200 OK

# Status API (read-only)

## GET /competitions.json
[1,2,3,4,5,...]

## GET /competitions/:competition_id/records.json
[{"id": ..., "competition_id": ..., "player_id": ..., "hits": 8, "kills": 2, ...}]

## GET /competitions/:competition_id/vessels.json
[{"id": ..., "competition_id": ..., "player_id": ..., "craft_url": ...}]

## GET /competitions/:competition_id/heats.json
[{"id": ..., "competition_id": ..., "player_id": ..., "vessel_id": ..., "stage": 1, ...}]

# Command API

## GET /competitions/:id.json
{"started_at": null, "ended_at": null, ...}

## GET /competitions/:id/start
200 OK

## GET /competitions/:id/end
200 OK

## GET /competitions/:competition_id/heats/:id/claim
200 OK

## GET /competitions/:competition_id/heats/:id/release
200 OK

