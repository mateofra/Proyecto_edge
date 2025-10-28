O obxectivo académico de este traballo é a demostración de competencia básica no uso dos distintos tipos de solucións tecnolóxicas que se traballaron nas prácticas da materia. 
Para acadar este obxectivo, o alumnado ten que atopar un conxunto de datos dentro dunha temática asignada, transformar os datos para poder ser importados nas distintas tecnoloxías de xestión de datos e resolver un pequeno conxunto de consultas de dificultade variada. As tecnoloxías consideradas son as seguintes:
1. Base de datos PostgreSQL con un modelo en primeira forma normal.
2. Base de datos PostgreSQL con un modelo complexo, que soporte tipos de datos compostos e arrays.
3. Base de datos PostgreSQL con tipo de datos JSON para soportar estruturas complexas.
4. Base de datos PostgreSQL con arquitectura distribuída (CiTUS Data)
5. Base de datos NoSQL con modelo documental MongoDB
6. Base de datos NoSQL con modelo de grafos Neo4J

## Modelo relacional

Utilizando como base a descrición da temática proporcionada, o grupo de traballo localizará os conxuntos de datos necesarios para preparar o contido dunha base de datos que debe de ter cando menos os seguintes elementos:
• Unha táboa que represente unha entidade con un atributo de texto dentro do que sexa necesario facer procuras por palabra clave.  
- **Biografía do loitador**  
• Un mínimo de tres táboas en total, relacionadas entre si, con cando menos unha relacion de tipo un a varios e outra de varios a varios.  
- **Loitador, Evento, Loita, Estilo**  
• Unha relación reflexiva ou un conxunto de relacións que formen un ciclo.  
- **Parceiro_principal**  
• Opcionalmente, poden incluírse atributos que almacenen representacións xeométricas das entidades.  
- **Localización dos estadios onde ocorren as loitas**  

Para conseguir o contido será posible combinar datos obtidos de un ou varios conxuntos de datos con datos xerados de forma manual ou automática.
Deben propoñerse entre 5 e 8 necesidades de información que requiran consultas SQL que involucren distintas partes da sintaxe da linguaxe.
1. Cando menos unha consulta debe precisar do JOIN entre como mínimo dúas táboas.
- **Listaxe de combates con nomes de loitadores e evento**
2. Cando menos unha consulta debe precisar do uso de funcións de agregado.
- **Contar as vitorias por método para cada loitador**
3. Cando menos unha consulta debe precisar do uso da cláusula GROUP BY
- **Contar as vitorias por método para cada loitador**
4. Cando menos unha consulta debe de precisar do uso da cláusula HAVING
- **Loitadores con máis de 5 vitorias por submisión**
5. Cando menos unha consulta debe de precisar do uso da cláusula UNION
- **Buscar loitadores especialistas en ou de **
6. Cando menos unha consulta debe de requirir a procura baseada en palabras clave sobre campos de texto.
- **Atopar loitadores cuxa biografía menciona "champion"**
7. Cando menos unha consulta debe de precisar a navegación varias veces (mais de dúas) a través da relación reflexiva ou do ciclo.
- **Cadea de adestramento****
8. Opcionalmente, pode incluírse algunha consulta espacial sobre as representacións xeométricas. Esta necesidade só é necesario resolvela coa tecnoloxía relacional.
- **Eventos realizados preto de**

Cada unha das necesidades de información deben de ser resoltas con código SQL que debe de ser explicado

## Modelo relacional estendido
Crearase un novo esquema dentro da base de datos para gardar os mesmos datos usando alternativas de modelado relacional que incorporen estruturas de agregación. En concreto, realizaranse as dúas tarefas seguintes.
Creación de tipos de datos compostos necesarios para almacenar os datos da base de datos no número mínimo de táboas, usando estruturas de agregación na�vas de PostgreSQL. Debe decidirse en que dirección se agregan os datos para conseguir isto. Despois de realizar as consultas da sección anterior sobre esta nova base de datos, ademais de explicar o código, debe de explicarse cales das consultas se ven beneficiadas polo orde de agregación e cales se verían prexudicadas.
Utilización do tipo de datos JSON para crear unha nova versión da base de datos con agregados, que de novo utilice o mínimo número de táboas. Utiliza unha dirección de agregación distinta a utilizada antes e explica cales serían agora as consultas beneficiadas e cales serían as prexudicadas.
Deben compararse os tempos de execución das consultas con: i) o modelo relacional, ii) o modelo con agreados na�vos de PostgreSQL e iii) o modelo con agregados implementados en JSON.

## Base de datos relacional distribuída
Nesta parte do proxecto executaranse as consultas do modelo relacional sobre un cluster.
Crearase un cluster de como mínimo 3 contedores, usando un coordinador e como mínimo 2 workers. Unha vez creado o cluster, importaremos os datos en formato relacional. Distribuiranse os datos entre os workers de forma axeitada de maneira que poidan resolverse as consultas propostas para a sección 3. Debe decidirse cales táboas deben de ser distribuídas e por que campo, e que táboas deben de ser replicadas en todos os nodos. Analizarase o impacto que ten sobre as consultas a parada de un dos dous nodos worker.
Deberase buscar información sobre o uso do formato columnar para as táboas de CITUS. Despois de borrar as táboas, debemos importar de novo as mesmas, pero agora usando este formato columnar na táboa ou táboas que consideres oportuno. Comproba o impacto no tempo de resposta das consultas o uso de este formato columnar.

## Base de datos NoSQL documental: MongoDB
Debe crearse un cluster de MongoDB seguindo a arquitectura que podes ver na imaxe de abaixo.
![arquitectura](img/img)  
Importa os datos da túa base de datos usando agregación e o número mínimo de coleccións JSON. Elixe a dirección de agregación e explica cales son as consultas beneficiadas e cales as prexudicadas. Indexa e particiona a colección (ou coleccións) da maneira que creas mais axeitada e despois resolve as consultas propostas na sección 3. Comproba o que ocorre coa execución das consultas se paras unha das máquinas (contedor docker). Fai a comprobación de novo parando dúas das máquinas. Fai probas con distintas opcións de preferencias e compromisos de lectura para ver o impacto que ten no comportamento das consultas cando tes paradas dúas das tres máquinas.

## Base de datos NoSQL de grafos: Neo4J
Deberá deseñarse un modelo de grafos para representar a información da base de datos utilizada nas seccións anteriores. Importaremos os datos a este modelo de datos en Neo4J directamente dende PostgreSQL usando unha conexión JDBC. Resolveremos as consultas propostas na sección 3. Explica as vantaxes que ten esta solución para a implementación da consulta que precisa navegar a través da relación reflexiva, respecto ao uso de tecnoloxías relacional.

## Criterios de evaluación

Para analizar a completitude analizaranse os seguintes aspectos:
• Tamaño e complexidade do conxunto de datos utilizado
• Cantidade e complexidade das necesidades de información propostas
• Cantidade de tarefas resoltas.
Para analizar a corrección das solucións teranse en conta os seguintes aspectos:
• Eficacia do código xerado (responde o código as necesidades previstas?)
• Eficiencia do código xerado (funciona o código cun tempo de execución e cun consumo
de memoria razoable?)
• Coherencia dos resultados obtidos
