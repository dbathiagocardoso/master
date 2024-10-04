/* --------------------------------------------------------------------------- */
/* VARIÁVEIS DE SISTEMA */
/* --------------------------------------------------------------------------- */

DECLARE @QUERY NVARCHAR(MAX)
       ,@QUERY_OUTPUT NVARCHAR(MAX)

/* --------------------------------------------------------------------------- */
/* VARIÁVEIS DE USUÁRIO */
/* --------------------------------------------------------------------------- */

DECLARE @SCHEMA NVARCHAR(MAX) = 'manufatura'
       ,@TABLE NVARCHAR(MAX) = 'lista_tecnica_realizadaXPOCalculosFalcon_Semanal'
       ,@MOSTRAR_ESTRUTURA_ORIGINAL BIT = 1 /* INFORMAR |0| PARA NÃO MOSTRAR E |1| PARA MOSTRAR A ESTRUTURA ORIGNAL DA TABELA */
       ,@STRING_TABLE BIT = 1               /* INFORMAR |0| PARA NÃO GERAR A STRING DE CRIAÇÃO DA TABLE E |1| PARA GERAR */
       ,@STRING_VIEW BIT = 1                /* INFORMAR |0| PARA NÃO GERAR A STRING DE CRIAÇÃO DA VIEW E |1| PARA GERAR */

/* --------------------------------------------------------------------------- */

SET @QUERY = 
	  'CONCAT('','', COLUNA_AJUSTADA) AS COLUNA_SELECT
	  ,CONCAT(''`'', COLUNA_AJUSTADA, ''`'', '' '', CASE WHEN DATA_TYPE IN (''VARCHAR'', ''NVARCHAR'', ''CHAR'') THEN ''STRING''
			                                       WHEN DATA_TYPE IN (''FLOAT'') THEN ''DOUBLE''
			                                  ELSE DATA_TYPE
		                                       END, '','') AS COLUNA_SCHEMA_TABLE
	  ,CONCAT(''`'', COLUNA_AJUSTADA, ''`'', '' AS '', ''`'',	COLUMN_NAME, ''`'', '','') AS COLUNA_SCHEMA_VIEW
  FROM (SELECT TABLE_SCHEMA
		      ,TABLE_NAME
		      ,COLUMN_NAME
		      ,ORDINAL_POSITION
		      ,DATA_TYPE
		      ,REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								TRANSLATE(
									TRANSLATE(
										LOWER(TRIM(COLUMN_NAME))
									, '' /-().'', ''____##'')
								,''��������'', ''aeioaaoc'')
						    ,''##'', '''')
						,''#'', '''')
					,''___'', ''_'')
			  ,''__'', ''_'') COLUNA_AJUSTADA
	FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = ''' + @SCHEMA + '''
	 AND TABLE_NAME = ''' + @TABLE + ''') A'


IF (@MOSTRAR_ESTRUTURA_ORIGINAL = 1) 
BEGIN
	
	SET @QUERY = 'SELECT *, ' + @QUERY

	EXECUTE SP_EXECUTESQL @QUERY

END
ELSE BEGIN

	SET @QUERY = 'SELECT ' + @QUERY

END

IF (@STRING_TABLE = 1)
BEGIN

	SET @QUERY_OUTPUT = 'SELECT STRING_AGG(SUBSTRING(COLUNA_SCHEMA_TABLE, 1, LEN(COLUNA_SCHEMA_TABLE) -1), '','') WITHIN GROUP (ORDER BY ORDINAL_POSITION ASC) AS STRING_CREATE_TABLE' 
	                   + ' FROM (' + @QUERY + ') AS STRING_TABLE'

	EXECUTE SP_EXECUTESQL @QUERY_OUTPUT	

END

IF (@STRING_VIEW = 1)
BEGIN

	SET @QUERY_OUTPUT = 'SELECT STRING_AGG(SUBSTRING(COLUNA_SCHEMA_VIEW, 1, LEN(COLUNA_SCHEMA_VIEW) -1), '','') WITHIN GROUP (ORDER BY ORDINAL_POSITION ASC) AS STRING_CREATE_VIEW' 
	                   + ' FROM (' + @QUERY + ') AS STRING_VIEW'

	EXECUTE SP_EXECUTESQL @QUERY_OUTPUT	

END