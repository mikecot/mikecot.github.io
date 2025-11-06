---
layout: post
title: "Building Scalable Blockchain Data Pipelines: Lessons from Processing 30+ Networks"
date: 2025-11-05 14:00:00 +0200
categories: blockchain-infrastructure
tags: [typescript, kafka, timescaledb, redis, scalability]
author: Mike Cotic
excerpt: "Deep dive into architecting high-performance data processing systems for multi-chain environments. Learn how we process millions of blockchain events in real-time using modern technologies."
---

# Building Scalable Blockchain Data Pipelines: Lessons from Processing 50M+ Daily RPC Events

Building infrastructure that can reliably process data from 30+ different blockchain networks isn't just about handling volume-it's about managing the complexity of different protocols, consensus mechanisms, and data structures while maintaining real-time performance. Over the past year at Lava Network, I've architected and built a comprehensive data pipeline that processes millions of blockchain events daily. Here's what I've learned.

## The Challenge: Multi-Chain Complexity at Scale

When you're building for a single blockchain like Ethereum, you can optimize for its specific characteristics. But when you need to support everything from Cosmos chains to Ethereum L2s to completely different architectures like Solana or Near, the challenge multiplies exponentially.

### Key Challenges We Faced:

1. **Heterogeneous Data Formats**: Each blockchain has its own event structure, transaction format, and block architecture
2. **Varying Block Times**: From Ethereum's ~12 seconds to Cosmos chains with 6-7 second blocks to high-frequency chains
3. **Different RPC Interfaces**: Each chain has its own API patterns and data access methods
4. **Scalability Requirements**: Processing millions of events while maintaining low latency for real-time analytics
5. **Reliability**: No data loss across network disruptions, chain reorganizations, and system upgrades

## Architecture Overview: The 4-Component Pipeline

After extensive prototyping and testing, we settled on a 4-component architecture that balances performance, reliability, and maintainability:

```
+---------------+    +----------------+    +-------------------+    +-------------+
|  Ingest API   |--->| Parser Worker  |--->| Metrics Loader    |--->| Stats API   |
|   (Gateway)   |    |  (Processor)   |    |  (Aggregator)     |    | (Frontend)  |
+---------------+    +----------------+    +-------------------+    +-------------+
       |                      |                       |                    |
       v                      v                       v                    v
   Chain RPCs            Kafka Topics           TimescaleDB           Redis Cache
```

### Component 1: Ingest API - The Universal Gateway

The ingest API serves as our universal gateway to blockchain data. Instead of building 30+ different data collectors, we created a unified interface that can adapt to any blockchain's RPC pattern.



### Component 2: Parser Worker - The Data Transformer

The parser worker is where the magic happens. It receives raw blockchain data via Kafka and transforms it into our unified data model while preserving chain-specific metadata.

**Design Principles:**
- **Failsafe Architecture**: Exponential backoff and retry mechanisms at each processing stage
- **Queue-Based Communication**: Dedicated message queues between all pod-to-service communications
- **Error Isolation**: Failed parsing of one event doesn't affect others
- **Batch Processing**: Optimized for throughput while maintaining order guarantees


### Component 3: Metrics Loader - The Aggregation Engine

TimescaleDB was chosen for its excellent time-series capabilities and PostgreSQL compatibility. The metrics loader performs real-time aggregations and builds the data structures that power our analytics.

**Aggregation Strategies:**
- **Time-Based Windows**: 1-minute, 5-minute, hourly, and daily aggregations
- **Chain-Specific Metrics**: RPC latency, block times, transaction throughput
- **Cross-Chain Analytics**: Comparative performance metrics and trend analysis
- **Continuous Aggregates**: Pre-computed rollups for fast query performance

**Sample Aggregation:**
```sql
CREATE MATERIALIZED VIEW hourly_chain_metrics
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 hour', timestamp) AS hour,
    chain_id,
    count(*) as total_transactions,
    avg(gas_used) as avg_gas_used,
    avg(block_time) as avg_block_time,
    count(DISTINCT block_height) as blocks_processed
FROM blockchain_events
GROUP BY hour, chain_id;
```

### Component 4: Stats API - The Performance Layer

The final component serves data to our various UIs and external consumers. Built with performance in mind, it combines TimescaleDB for historical data with Redis for real-time caching.

**Performance Optimizations:**
- **Multi-Layer Caching**: L1 (in-memory), L2 (Redis), L3 (TimescaleDB)
- **Query Optimization**: Pre-computed aggregates and intelligent query planning
- **Connection Pooling**: Efficient database connection management

## Technology Deep Dive

### Why Bun Runtime?

We chose **Bun** as our JavaScript runtime for several compelling reasons:

1. **Performance**: 3-4x faster startup times compared to Node.js
2. **Built-in Tools**: Native bundling, testing, and package management
3. **Modern Standards**: First-class TypeScript support without compilation overhead
4. **Memory Efficiency**: Lower memory footprint for our worker processes

**Performance Comparison:**
```bash
# Cold start times (average of 100 runs)
Node.js:  2.3s
Bun:      0.6s

# Memory usage (steady state)
Node.js:  185MB per worker
Bun:      127MB per worker
```

### Kafka for Event Streaming

**Kafka** provides the backbone for our event streaming with several key configurations:

```yaml
# Optimized for throughput and reliability
batch.size: 1048576  # 1MB batches
linger.ms: 100       # Small latency for responsiveness
compression.type: snappy
acks: all            # Ensure durability
retries: 2147483647  # Infinite retries
```

**Topic Strategy:**
- `raw-events-{chainId}`: Raw blockchain data per chain
- `processed-events`: Unified processed events
- `metrics-updates`: Real-time metric updates
- `alerts`: System health and anomaly notifications

### TimescaleDB Optimizations

**Partitioning Strategy:**
```sql
-- Partition by time and chain for optimal query performance
SELECT create_hypertable(
    'blockchain_events',
    'timestamp',
    partitioning_column => 'chain_id',
    number_partitions => 32
);

-- Optimize for time-range queries
CREATE INDEX ON blockchain_events (timestamp DESC, chain_id);
CREATE INDEX ON blockchain_events (chain_id, timestamp DESC);
```

**Compression Policies:**
```sql
-- Compress data older than 7 days
SELECT add_compression_policy('blockchain_events', INTERVAL '7 days');
```

## Performance Metrics & Results

After 6 months in production, our pipeline consistently delivers impressive performance:

### Throughput Metrics
- **Peak Processing Rate**: 50,000 events/second
- **Average Latency**: End-to-end processing under 2 seconds
- **Storage Efficiency**: 80% compression ratio on historical data
- **Query Performance**: 95th percentile queries under 200ms

### Reliability Metrics
- **Uptime**: 99.9% availability
- **Data Accuracy**: 100% - zero data loss incidents
- **Recovery Time**: Under 60 seconds for component failures
- **Scalability**: Linear scaling up to 100 worker processes

### Resource Utilization
```
Component          CPU Usage    Memory Usage    Storage
Ingest API         15-25%       2GB             -
Parser Workers     40-60%       8GB             -
Metrics Loader     20-35%       4GB             -
Stats API          10-20%       1GB             -
TimescaleDB        30-50%       16GB            2TB
Redis              5-15%        4GB             -
DragonflyDB        3-8%         2GB             -
Kafka              20-30%       6GB             500GB
```

**Note**: We use Redis as primary cache with DragonflyDB as a high-performance replica for read-heavy workloads, providing enhanced throughput and reduced latency for analytics queries.

## Advanced Technical Implementation

### Dual-Pool Database Architecture

The system implements a sophisticated **Read/Write Separated Connection Pool** architecture for optimal database performance:

```typescript
// Read Pool - Optimized for query performance
readPool: {
    max: 20,              // Maximum connections
    min: 5,               // Minimum connections
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
    maxUses: 7500,        // Connection recycling
    query_application_timeout: 120000  // 2 minutes
}

// Write Pool - Optimized for write throughput  
writePool: {
    max: 10,              // Fewer connections for writes
    min: 2,
    maxUses: 7500,
    query_application_timeout: 120000
}
```

### Latency Distribution System

Implemented uncapped latency tracking with 7-bucket classification system for internal analytics:

**Latency Buckets:**
- 0-100ms: Fast responses
- 100-200ms: Good responses  
- 200-300ms: Acceptable responses
- 300-400ms: Slow responses
- 400-500ms: Very slow responses
- 500-1000ms: Outlier responses
- 1000ms+: Critical outliers

**Daily Aggregation:** Each chain/day record stores 14 additional columns (count + sum per bucket) enabling precise latency distribution analysis while maintaining public API backward compatibility with 500ms capped values.

### Kafka Optimization Strategy

**Batch Size Hierarchy:**
```
CloudFlare Logs (70,000+ entries)
  └─> SendEntries splits (20,000 entries/call) 
      └─> BatchManager buffers (15,000 default, max 20,000)
          └─> Kafka chunks (5,000 entries)
              └─> Final safety batches (2,000 entries)
```

**Producer Configuration:**
- Message max: 1GB (1,073,741,824 bytes)
- Batch size: 10MB (10,485,760 bytes)
- Linger: 10ms for optimal batching
- Socket buffer: 1GB for high throughput

**Consumer Optimization:**
- 10 partitions for parallel processing
- 100MB max fetch per partition
- 20 parallel workers per consumer
- Circuit breaker protection with exponential backoff

### PostgreSQL Performance Tuning

**Aggressive Memory Configuration:**
```yaml
shared_buffers: 8GB                    # 2x increase for better caching
maintenance_work_mem: 4GB              # 4x increase for faster aggregations
work_mem: 256MB                        # 4x increase for complex queries
wal_buffers: 256MB                     # 4x increase for write performance
```

**Parallel Processing:**
- 16 max worker processes
- 8 parallel workers per query
- 8 parallel maintenance workers
- 300 effective I/O concurrency

**Query Optimization:**
- Statistics target: 500 (5x default)
- Random page cost: 1.0 (SSD optimized)  
- CPU costs reduced for modern hardware
- Genetic query optimization for complex joins

### Circular Buffer Management

**Real-time Data Storage:**
```typescript
// Fixed-size buffers with FIFO eviction
buffers: Map<string, CircularBuffer<LogEntryData>>
geoBuffers: Map<string, CircularBuffer<GeoPoint>>

// Buffer configuration
- Size: 5,000 entries per buffer
- Memory: ~2MB per buffer
- TTL: 1 hour automatic expiration
- Thread-safe operations
```

**Buffer Types:**
- Global entries (all chains)
- Chain-specific entries (per blockchain)
- Provider-specific entries (per RPC provider)
- Geographic point aggregation (lat/lon data)


## Conclusion

Building scalable blockchain data infrastructure is a complex challenge that requires careful consideration of performance, reliability, and cost. The key is to design for the inherent complexity and unpredictability of the blockchain ecosystem while maintaining the flexibility to adapt to rapid protocol evolution.

Our architecture at Lava Network has proven that it's possible to process massive volumes of multi-chain data in real-time while maintaining high reliability and performance. The combination of modern technologies like Bun, Kafka, and TimescaleDB, coupled with thoughtful system design, enables us to provide valuable insights across the entire blockchain ecosystem.

Whether you're building analytics platforms, DeFi protocols, or blockchain explorers, these patterns and principles can help you create robust, scalable infrastructure that can handle the demands of modern multi-chain applications.

---

**Navigation:**
[← Prev](/blockchain-infrastructure/2025/10/03/internal-rpc-analytics.html) | [Next →](/scams-in-the-wild/2025/11/05/linkedin-malicious-npm-package-malware.html)

