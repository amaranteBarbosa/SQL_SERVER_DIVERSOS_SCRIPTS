--AMARANTE  fev/2022


---*************************************************
---CRIAÇÃO DA TABELA JÁ COM VERSIONAMENTO    *******
---*************************************************
CREATE TABLE tbver01
(
    codigo INT NOT NULL PRIMARY KEY CLUSTERED
  , nome VARCHAR(50) NOT NULL
  , SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
  , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
  , PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.hist_tbver01));

---*************************************************
---******* VERSIONANDO UMA TABELA JÁ EXISTENTE *****
---*************************************************
/*
-->Criar na tabela a ser versionada a estrutura necessária
   Criar duas colunas SYSSTARTTIME e SYSENDTIME cada uma delas
     com uma restrição PADRÃO de DATAS
*/
--Obrigatoriamente a tabela tem que ter CHAVE PRIMÁRIA
--> Se por acaso a coluna que será a chave primária 
--aceitar NULOS, modificar
ALTER TABLE tbversionada
   ALTER COLUMN codigo varchar(50)  NOT NULL

--Criar a chave primária
ALTER TABLE tbversionada
   ADD CONSTRAINT pk_codigo PRIMARY KEY 
   CLUSTERED (codigo);

ALTER TABLE tbversionada
    ADD
        SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_SysStart DEFAULT SYSUTCDATETIME()
      , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_SysEnd DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
        PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
GO
--Ativar o versionamento criando a tabela de histórico
ALTER TABLE tbversionada
    SET (SYSTEM_VERSIONING = ON 
	(HISTORY_TABLE = dbo.Hist_tbversionada));

---************************************************************
---REMOVENDO PERMANENTEMENTE O SISTEMA DE VERSIONAMENTO *******
---************************************************************
ALTER TABLE tbversionada SET (SYSTEM_VERSIONING = OFF);
---
ALTER TABLE tbversionada
DROP PERIOD FOR SYSTEM_TIME;
---
--Excluir as restrições
ALTER TABLE tbversionada drop constraint DF_SysEnd
ALTER TABLE tbversionada drop constraint DF_SysStart
--Excluir as coluna
ALTER TABLE tbversionada drop column SysStartTime
ALTER TABLE tbversionada drop column SysEndTime
---*********************************************************
---REMOÇÃO TEMPORÁRIO DO SISTEMA DE VERSIONAMENTO    *******
--Desligando
ALTER TABLE tbversionada SET (SYSTEM_VERSIONING = OFF);
------------------------------------------------------------
---Ligando
ALTER TABLE tbversionada SET
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tbversionada)
);
COMMIT ;
