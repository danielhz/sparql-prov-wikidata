# sparql-prov-wikidata

Experiments to benchmark performance of query rewriting techniques for
provenance of SPARQL queries using the Wikidata dataset.

## Setting up the machine

These experiments are designed to run in different machines.  Machine
configuration, benchmark results, and information about tasks that
have been done are saved and tracked in the `machines` directory. Each
machine has a separate folder. In the current version we have the
following structure:

```
machines/
├── a256
│   ├── config
│   ├── results
│   └── task_status
└── a64
    ├── config
    ├── results
    └── task_status
```

To start runing the benchmark tasks you have to activate the machine
you will use.  This is done by creating a symbolic link to the
machine. For instance, we can activate machine `a256` as follows:

```
ln -s machines/a256 active_machine
```

