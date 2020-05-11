# CRDT

Swift implementation of state based CRDT (CvRDT)

## What is CRDT?

Conflict-free Replicated Data types or CRDT for short are data types which support semilattice properties and able to resolve conflicts connected with concurrent changes automatically. They were designed as a solution for data synchonization problem in distibuted systems, that's why they are highly connected with _version vector_.

More info in [CRDT whitepaper](https://hal.inria.fr/inria-00555588/document) and [Version vector (wiki)](https://en.wikipedia.org/wiki/Version_vector)

## Portfolio of implemented CvRDT

Current implementation contains next data structures:
- counters: `GCounter`, `PNCounter`
- registers: `LWWRegister`, `MVRegister`
- sets: `GSet`, `2PSet` (called as `TPSet`), `ORSet` (same as `AWSet`)
- maps: `ORMap` (same as `AWMap`)
- flags: `EWFlag`

Also it contains next logical timestamps which are used by `GCounter` and `MVRegister`:
- `VersionVector` (it is highly possible that it will be deprecated in future, because it is not match dynamic distibuted systems which we have in iOS development)
- `VectorStamp`

## Example

You can find example of usage based on client-server app [here](https://github.com/specialfor/TodoMVC-Swift-CRDT) 

## Future plans

- [ ] Improve existed implementation:
  - [ ] Start using `VectorStamp` instead of `VersionVector` inside `GCounter`
  - [ ] Rethink timestamp usage in `LWWRegister`
- [ ] Add more CvRDTs:
  - [ ] POCounter
  - [ ] PNSet
  - [ ] LWWSet
  - [ ] RWSet
  - [ ] Log
  - [ ] RWMap
  - [ ] DWFlag
  - [ ] DAG
  - [ ] RGA
  - [ ] WOOT
  - [ ] Treedoc
  - [ ] Lagoot
- [ ] Implement gargbage collector
- [ ] Introduce delta CRDT
- [ ] Create CmRDT analogues

