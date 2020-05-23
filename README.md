# [valar-schema](https://github.com/dmyersturnbull/valar-schema)

Schema for Valar.
- `schema.sql` ... core database
- `views.sql` ... table views
- `mandos.sql` ... cheminformatcs and expression data
- `queue.sql` ... Airflow queue for inserting jobs
- `scripts/` ... Potentially useful scripts

**NOTE:** This repository is slightly out-of-date.


## Notes about tables

#### Compound IDs and names

There are a number of ID, which all mean different things. A _compound_ corresponds to an Inchi string, which is a unique representation of a chemical structure. Note that this forbids mixtures. An _batch_ is a stock/batch of a compound, mixture, or _exposure_; it refers to the compound (if possible), purchase date, location, and supplier. An exposure is something like heat or shaking. A batch can have a _tag_, which is a unique name. This is not necessary for batches corresponding to compounds, but is critical for mixtures and exposures. For example, wasabi should have a tag called "wasabi".

No two different chemical structures have the same `compounds.inchi`, `compounds.inchikey`, or `compounds.smiles`. A structure can have multiple SMILES but only one Inchi and Inchikey. Inchikeys are great for lookups because they’re short, but you can’t determine a structure without the full Inchi. `compounds.inchikey_connectivity` uniquely describes a configuration of atoms without stereochemistry.

#### How frames and features are stored

Modern relational databases do not permit array types for some conceptual reasons. Unfortunately, this is tricky in our case. To work around this, `assay_frames.frames` stores data as a block of unsigned big-endian bytes in a `blob`. `well_features` stores data as a block of big-endian unsigned IEEE 754 binary32 floats; so every 4 bytes constitutes a float. Because Java and Scala only have signed types, these are interconverted.

#### How hashes are defined

First, there are two _lookup_ hashes designed to prevent accidental typos:
- `batches.lookup_hash` is a 8-digit truncation the hex sha1 of `batches.id`
- `submissions.lookup_hash` is a randomly generated 12-digit hex string

Assays and batteries have hashes that have precise definitions. Each uses JVM big-endian signed numbers.
There is code to help with this in `AssayAndProtocolUtils.scala`.

- An assay hash is the sha1 of the concatenation: *s_1 h_1 ... s_m h_m*,
where the order *1, ..., m* is given by the stimulus_frames objects *s_1, ..., s_m* sorted by ID descending,
and each *h_i* is the stimulus_frames hash for row *i*.
- A battery hash is the sha1 of the concatenation: *a_1 ℓ_1 ... a_n ℓ_n*,
where the order *1, ..., n* is from start to finish, each *a_i* is the hash of assay *i*, and each *ℓ_i* is the length of assay *i*.

- `stimulus_frames` are equal iff their source IDs and hashes are the same
- `assays` are equal iff their lengths and their hashes are the same
- `batteries` are equal iff their hashes are the same
