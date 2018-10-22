mvn install:install-file -DgroupId=com.ldbc.snb -DartifactId=cypher -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar -Dfile=../cypher/target/cypher-0.0.1-SNAPSHOT.jar
mvn install:install-file -DgroupId=com.ldbc.snb -DartifactId=common -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar -Dfile=../common/target/common-0.0.1-SNAPSHOT.jar
mvn assembly:single -DskipTests
