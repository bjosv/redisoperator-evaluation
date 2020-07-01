# KubeDB:
- More complex dependecy graf (?)   TODO: Get list of dep ????  go list -m all
# RedisOperator:
- ..

---------------------------------
# License
## KubeDB:
- Apache-2.0
## Redis-Operator:
- MIT

---------------------------------
# Repo
## KubeDB:
- 9 repos (redis only)

apimachinery
cli
docs
installer
operator
project
redis
redis-docker
redis-exporter-docker

## Redis-Operator:
- 1 repo

---------------------------------
# Go files
find . -name "*.go" | grep "/vendor/"  | wc -l
find . -name "*.go" | grep -v "/vendor/"  | wc -l

## KubeDB:
non-vendor:   403
vendor:     17775
## Redis-Operator:
non-vendor:   116
vendor:      6293

---------------------------------
# Lines (of code?)
~/go/src/github.com/amadeusitgroup/redis-operator
~/git/kubedb

find . -name "*.go" | grep "/vendor/"  | xargs wc -l
find . -name "*.go" | grep -v "/vendor/"  | xargs wc -l

## KubeDB (9 repos):
non-vendor: 199719 lines
vendor: 216997 lines
operator (non-vendor): 1388
redis (non-vendor): 7739
redis (vendor): 147806

## Redis-Operator:
non-vendor: 15372 lines
vendor: 776431 lines

---------------------------------
# Contributors

## KubeDB:
### apimachinery
21 contributors
Companies
- Appscode 7 + 2ex.
- Pixmama (Photo stock)
- Pathao Ltd (Transport, Bangladesh)
- KickbackApps (App dev, Bangladesh)
- Syncromatics (SW company, LA/US)
- Intel (Germany)
- Grafana Labs (Germany)
### cli
26 contributors
Companies
- Appscode 3 + 1ex.
- KickbackApps (App dev, Bangladesh)
- Rungway (social health)
- rapyuta-robotics (robotics)
- avito-tech (Russia)
- Plotly (Data science, NY/US)
- Fits4all (Consultant, Netherlands)
- INNOQ (Consultant, Germany)
- Syncromatics (SW company, LA/US)
- Tower Research Capital (Finacial)
### docs
28 contributors
### installer
23 contributors
### operator
7  contributors + 1 bot
Companies:
- Appscode
- Digital Health (Health, Bangladesh, a former AppsCode employer)
### project
2 contributors
Companies
- Appscode 1 + 1ex.
### redis
11 in total
Companies:
- Appscode
- Pathao Ltd (Transport, Bangladesh)
### redis-docker
1 in total
Companies:
- Appscode
### redis-exporter-docker
1 in total
Companies:
- Appscode

Total:
Companies
- Appscode
- Digital Health (Health, Bangladesh, former AppsCode employer)
- Pathao Ltd (Transport, Bangladesh)
- KickbackApps (App dev, Bangladesh)
- Rungway (social health)
- rapyuta-robotics (robotics)
- avito-tech (Russia)
- Plotly (Data science, NY/US)
- Fits4all (Consultant, Netherlands)
- INNOQ (Consultant, Germany)
- Syncromatics (SW company, LA/US)
- Tower Research Capital (Finacial)
- Intel (Germany)
- Grafana Labs (Germany)


## Redis-Operator:
9 in total
8 individs
Companies:
- Amadeus (Travel)
- G-Research (finance research firm)

---------------------------------
# Activity

## KubeDB:
Feb 27, 2017 (repo: kubedb/cli)
Redis since Nov 2017

apimachinery - 667 commits
cli          - 613 commits
docs         - 280 commits
installer    - 291 commits
operator     - 282 commits
project      - 10 commits
redis        - 241 commits
redis-docker - 4 commits per version: 6.0.5/5.0.3/4.0.11
redis-exporter-docker - 3 commits

Last commit: daily

## Redis-Operator:
April 23 2018
37 commits
Last commit: Sep 23 2019
