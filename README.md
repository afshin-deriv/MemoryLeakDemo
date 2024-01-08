
## Overview
This is a sample Perl code repository demonstrating a race condition scenario in Perl program that uses `fmap_concat` and `Net::Async::Redis::Multi`.

## Setup
To reproduce the scenarios, follow these steps:

1. Clone this repository:

   ```bash
   git clone git@github.com:afshin-deriv/MemoryLeakDemo.git
   ```
2. Navigate to the project directory:
   ```bash
   cd MemoryLeakDemo
   ```
## Memory Leak Demonstration
3. Run the Docker Compose setup:
   ```bash
   docker-compose up -d -f docker-compose-memory.yml
   ```

4. After running the Docker Compose setup, observe the memory usage of the Docker container by executing:

   ```bash
   docker stats --format "table {{.Container}}\t{{.MemUsage}}"
   ```
You should notice a continuous increase in memory usage, indicating the presence of a memory leak in the Perl code.

###  DEADLock Demonstration
3. Run the Docker Compose setup:
   ```bash
   docker-compose -f docker-compose-deadlock.yml up -d
   ```

4. After running the Docker Compose setup, observe the output of the `perl-script` service. The `fmap_concat` command never finishes.
   ```bash
   docker-compose -f docker-compose-deadlock.yml logs perl-script
   ```


## Race Condition Demonstration
Additionally, this repository includes a simple Perl script that, due to a race condition, may never end as expected. Explore the code and run it to observe the unexpected behavior.

## Tear down
```
docker-compose -f docker-compose-deadlock.yml down --rmi all
docker-compose -f docker-compose-memory.yml down --rmi all
```
