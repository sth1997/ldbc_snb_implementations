# Generate queries using C2S transpiler

```shell
# for first time
git clone https://github.com/FTSRG/ingraph.git
cd ingraph
git checkout cypher-to-sql

# if used before
git pull
rm cypher-to-sql/ldbc_snb_implementations/postgres/queries-generated/*

./gradlew :cypher-to-sql:clean :cypher-to-sql:test --tests ingraph.compiler.sql.driver.LdbcParameterizedQueriesTest
```
Use queries by copying next to this README.md from `cypher-to-sql/ldbc_snb_implementations/postgres/queries-generated/`.
