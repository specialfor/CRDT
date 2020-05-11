# 📝 CRDT
![Swift version badge](https://img.shields.io/badge/Swift-5.2-green) ![Platforms badge](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20Linux-lightgrey)

Swift implementation of state based CRDT (CvRDT)

## ❓ What is CRDT?

Conflict-free Replicated Data types or CRDT for short are data types which support semilattice properties and able to resolve conflicts connected with concurrent changes automatically. They were designed as a solution for data synchonization problem in distibuted systems, that's why they are highly connected with _version vector_.

More info in [CRDT whitepaper](https://hal.inria.fr/inria-00555588/document) and [Version vector (wiki)](https://en.wikipedia.org/wiki/Version_vector)

## 💼 Portfolio of implemented CvRDT

Current implementation contains next data structures:
- counters: `GCounter`, `PNCounter`
- registers: `LWWRegister`, `MVRegister`
- sets: `GSet`, `2PSet` (called as `TPSet`), `ORSet` (same as `AWSet`)
- maps: `ORMap` (same as `AWMap`)
- flags: `EWFlag`

Also it contains next logical timestamps which are used by `GCounter` and `MVRegister`:
- `VersionVector` (it is highly possible that it will be deprecated in future, because it is not match dynamic distibuted systems which we have in iOS development)
- `VectorStamp`

## 🔧 Install

Only SPM is supported:
```
dependencies: [
        .package(url: "https://github.com/specialfor/CRDT", .branch("develop"))
]
```

## 📲 Usage

Feel free to look into [tests folder](https://github.com/specialfor/CRDT/tree/develop/Tests/CRDTTests/CRDT/CRDT).
You can also find an example of usage based on client-server app [here](https://github.com/specialfor/TodoMVC-Swift-CRDT) 

## 🤔 Future plans

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

