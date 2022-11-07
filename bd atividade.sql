 drop database dbDistribuidoraa;

-- criando db e pondo em uso
create database dbDistribuidoraa;
use dbDistribuidoraa;
-- criando tabelas
create table tbUF (
 IdUF int auto_increment primary key,
 UF char(2) unique
);

create table tbBairro (
 IdBairro int auto_increment primary key,
 Bairro varchar(200)
);

create table tbCidade (
 IdCidade int auto_increment primary key,
 Cidade varchar(200)
);

create table tbEndereco (
 CEP decimal(8,0) primary key,
 Logradouro varchar(200),
 IdBairro int,
 foreign key (IdBairro) references tbBairro(IdBairro),
 IdCidade int,
 foreign key (IdCidade) references tbCidade(IdCidade),
 IdUF int,
 foreign key (IdUF) references tbUF(IdUF)
);

create table tbCliente (
 Id int primary key auto_increment,
 NomeCli varchar(50) not null,
 CEPCli decimal(8,0) not null,
 NumEnd decimal(6,0) not null,
 CompEnd varchar(50),
 foreign key (CEPCli) references tbEndereco(CEP)
);

create table tbClientePF (
 IdCliente int ,
 foreign key (IdCliente) references tbCliente(Id),
 Cpf decimal(11,0) not null primary key,
 Rg decimal(8,0),
 RgDig char(1),
 Nasc date
);

create table tbClientePJ (
 IdCliente int ,
 foreign key (IdCliente) references tbCliente(Id),
 Cnpj decimal(14,0) not null primary key,
 Ie decimal(11,0)
);

create table tbNotaFiscal (
 NF int primary key,
 TotalNota decimal(7, 2) not null,
 DataEmissao date not null
);

create table tbFornecedor (
 Codigo int primary key auto_increment,
 Cnpj decimal(14,0) unique not null,
 Nome varchar(200) not null,
 Telefone decimal(11,0)
);

create table tbCompra (
 NotaFiscal int primary key,
 DataCompra date default(current_timestamp()) not null,
 ValorTotal decimal(8, 2) not null,
 QtdTotal int not null,
 Cod_Fornecedor int,
 foreign key (Cod_Fornecedor) references tbFornecedor(Codigo)
);

create table tbProduto (
 CodBarras decimal(14,0) primary key,
 Nome varchar(200) not null,
 Qtd int,
 ValorUnitario decimal(6, 2) not null
);

create table tbItemCompra (
 Qtd int not null,
 ValorItem decimal(6, 2) not null,
 NotaFiscal int,
 CodBarras decimal(14,0),
 primary key (Notafiscal, CodBarras),
 foreign key (NotaFiscal) references tbCompra(NotaFiscal),
 foreign key (CodBarras) references tbProduto(CodBarras)
);

create table tbVenda (
 IdCliente int not null,
 foreign key (IdCliente) references tbCliente(Id),
 NumeroVenda int primary key auto_increment,
 DataVenda datetime not null default(current_timestamp()),
 TotalVenda decimal(7, 2) not null,
 NotaFiscal int,
 foreign key (NotaFiscal) references tbNotaFiscal(NF)
);

create table tbItemVenda (
 NumeroVenda int auto_increment,
 CodBarras decimal(14,0),
 foreign key (NumeroVenda) references tbVenda(NumeroVenda),
 foreign key (CodBarras) references tbProduto(CodBarras),
 Qtd int not null,
 ValorItem decimal(6, 2) not null
);

-- criando procedures - 'atalhos'
delimiter $$
create procedure spInsertForn(vNome varchar(200), vCNPJ decimal(14,0), vTelefone decimal(11,0))
begin
	if not exists (select CNPJ from tbFornecedor where CNPJ = vCNPJ) then
		insert into tbFornecedor(Nome, CNPJ, Telefone) values (vNome, vCNPJ, vTelefone);
	else
		select 'Já Existe';
	end if;
end $$

delimiter $$
create procedure spInsertCidade(vCidade varchar(200))
begin
if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
	insert into tbCidade(Cidade) values (vCidade);
end if;
end $$

delimiter $$
create procedure spInsertUF(vUF char(2))
begin
if not exists (select IdUf from tbUF where UF = vUF) then
	insert into tbUF(UF) values (vUF);
end if;
end $$

delimiter $$
create procedure spInsertBairro(vBairro varchar(200))
begin
if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
	insert into tbBairro(Bairro) values (vBairro);
end if;
end $$

delimiter $$
create procedure spInsertProduto(vCodBarras decimal(14,0), vNome varchar(200), vValorUnitario decimal(6, 2), vQtd int)
begin
	if not exists (select CodBarras from tbProduto where CodBarras = vCodBarras) then
		insert into tbProduto(CodBarras, Nome, ValorUnitario, Qtd) values (vCodBarras, vNome, vValorUnitario, vQtd); 
	else
		select 'Já Existe';
    end if;
end $$

delimiter $$
create procedure spInsertEndereco(vCEP decimal(8,0), vLogradouro varchar(200), vBairro varchar(200), vCidade varchar(200), vUF char(2))
begin
if not exists (select CEP from tbEndereco where CEP = vCEP) then
	if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
		insert into tbBairro(Bairro) values (vBairro);
	end if;

	if not exists (select IdUf from tbUF where UF = vUF) then
		insert into tbUF(UF) values (vUF);
	end if;

	if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
		insert into tbCidade(Cidade) values (vCidade);
	end if;

	set @IdBairro = (select IdBairro from tbBairro where Bairro = vBairro);
	set @IdUf = (select IdUF from tbUF where UF = vUf);
	set @IdCidade = (select IdCidade from tbCidade where Cidade = vCidade);

	insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values
	(vCEP, vLogradouro, @IdBairro, @IdCidade, @IdUF); 
end if;
end $$

delimiter $$
create procedure spInsertCliente (vNome varchar(50), vNumEnd decimal(6,0), vCompEnd varchar(50), vCEP decimal(8,0), vCPF decimal(11,0), vRG decimal(8,0), vRgDig char(1), vNasc date,
vLogradouro varchar(200), vBairro varchar(200), vCidade varchar(200), vUF char(2))
begin
   	if not exists (select CPF from tbClientePF where CPF = vCPF) then
		if not exists (select CEP from tbEndereco where CEP = vCEP) then
			if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
				insert into tbBairro(Bairro) values (vBairro);
			end if;

			if not exists (select IdUf from tbUF where UF = vUF) then
				insert into tbUF(UF) values (vUF);
			end if;

			if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
				insert into tbCidade(Cidade) values (vCidade);
			end if;

			set @IdBairro = (select IdBairro from tbBairro where Bairro = vBairro);
			set @IdUf = (select IdUF from tbUF where UF = vUf);
			set @IdCidade = (select IdCidade from tbCidade where Cidade = vCidade);

			insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values
			(vCEP, vLogradouro, @IdBairro, @IdCidade, @IdUF); 
		end if;
    
		insert into tbCliente(NomeCli, CEPCli, NumEnd, CompEnd) values (vNome, vCEP, vNumEnd, vCompEnd);
        set @CodigoCliente = (select ID from tbCliente order by ID desc limit 1 );
		insert into tbClientePF(IdCliente, CPF, RG, RgDig, Nasc) values (@CodigoCliente, vCPF, vRG, vRgDig, vNasc);
	else
		select "Existe";
	end if;
end $$

delimiter $$
create procedure spInsertCliPJ (vNome varchar(50), vCNPJ decimal(14,0), vIE decimal(11,0), vCEP decimal(8,0), vLogradouro varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50),
vBairro varchar(200), vCidade varchar(200), vUF char(2))

begin
    if not exists (select Cnpj from tbClientePJ where Cnpj = vCNPJ) then
		if not exists (select CEP from tbEndereco where CEP = vCEP) then
			if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
				insert into tbBairro(Bairro) values (vBairro);
			end if;

			if not exists (select IdUf from tbUF where UF = vUF) then
				insert into tbUF(UF) values (vUF);
			end if;

			if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
				insert into tbCidade(Cidade) values (vCidade);
			end if;

			set @IdBairro = (select IdBairro from tbBairro where Bairro = vBairro);
			set @IdUf = (select IdUF from tbUF where UF = vUf);
			set @IdCidade = (select IdCidade from tbCidade where Cidade = vCidade);

			insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values
			(vCEP, vLogradouro, @IdBairro, @IdCidade, @IdUF); 
            
		end if;
        
			insert into tbCliente(NomeCli, CEPCli, NumEnd, CompEnd) value(vNome, vCEP, vNumEnd, vCompEnd);
            set @CodigoCliente = (select ID from tbCliente order by ID desc limit 1 );
			insert into tbClientePJ(IdCliente,Cnpj, Ie) value (@CodigoCliente, vCNPJ, vIE);
	else
		select "Existe";
	end if;
end $$

delimiter $$
create procedure spInsertCompra(vNotaFiscal int, vFornecedor varchar(200), vDataCompra date, vCodBarras decimal(14,0), vValorItem decimal(6,2),
vQtd int, vQtdTotal int, vValorTotal decimal(8,2))
begin
	if not exists (select NotaFiscal from tbCompra where NotaFiscal = vNotaFiscal) then
		insert into tbCompra(NotaFiscal, DataCompra, ValorTotal, QtdTotal, Cod_Fornecedor) values (vNotaFiscal, vDataCompra, vValorTotal, vQtdTotal,
        (select codigo from tbFornecedor where Nome = vFornecedor));
	end if;
        insert into tbItemCompra(Qtd, ValorItem, NotaFiscal, CodBarras) values (vQtd, vValorItem, vNotaFiscal, vCodBarras);
end $$

delimiter $$
create procedure spInsertVenda(vCliente varchar(200), vCodBarras decimal(14,0), vQtd int, vNF int)
begin
	if exists (select * from tbProduto,tbCliente where CodBarras = vCodBarras and NomeCli = vCliente) then
		set @IdCli = (select Id from tbCliente where NomeCli = vCliente);
		set @CodBarras = (select CodBarras from tbProduto where CodBarras = vCodBarras);
		set @Valor = (select ValorUnitario from tbProduto where CodBarras = vCodBarras);
		insert into tbVenda(IdCliente, TotalVenda, NotaFiscal) values (@IdCli, (@valor * vQtd), vNF);
		set @CodigoVenda = (select NumeroVenda from tbVenda order by NumeroVenda desc limit 1 );
	
	if not exists (select * from tbItemVenda where NumeroVenda = @CodigoVenda) then
        insert into tbItemVenda(NumeroVenda, CodBarras, Qtd, ValorItem) values (@CodigoVenda, @CodBarras, vQtd, @Valor);
	end if;
    end if;
end $$

delimiter $$
create procedure spInsertNF(vNF int, vCliente varchar(200), vDataEmissao char(10))
begin
	set @IdCli = (select Id from tbCliente where NomeCli = vCliente);
    set @DataEmissao = str_to_date(vDataEmissao, "%d/%m/%y");
	set @ValorTotal = (select sum(TotalVenda) from tbVenda where IdCliente = @IdCli);

	if not exists (select NF from tbNotaFiscal where NF = vNF) then
		insert into tbNotaFiscal(NF, TotalNota, DataEmissao) values (vNF, @ValorTotal, @DataEmissao);
	end if;

   	if not exists (select NotaFiscal from tbVenda where NotaFiscal = vNF) then
		update tbVenda set NotaFiscal = vNF where IdCliente = @IdCli;
	end if;
end $$

delimiter $$
create procedure spDeleteProd(vCodBarras decimal(14,0))
	begin
		if exists (select CodBarras from tbProduto where CodBarras = vCodBarras) then
			delete from tbProduto where CodBarras = vCodBarras;
		end if;
    end;
$$

delimiter $$
create procedure spUpdateProd(vCodBarras decimal(14,0), vNome varchar(200), vValorUnitario decimal(6, 2))
	begin
		if exists (select CodBarras from tbProduto where CodBarras = vCodBarras) then
			update tbProduto set Nome = vNome, ValorUnitario = vValorUnitario where CodBarras = vCodBarras;
		end if;
    end;
$$

-- chamando os atalhos
call spInsertForn('Revenda Chico Loco', 1245678937123, 11934567897);
call spInsertForn('José Faz Tudo S/A', 1345678937123, 11934567898);
call spInsertForn('Vadalto Entregas', 1445678937123, 11934567899);
call spInsertForn('Astrogildo das Estrela', 1545678937123, 11934567800);
call spInsertForn('Amoroso e Doce', 1645678937123, 11934567801);
call spInsertForn('Marcelo Dedal', 1745678937123, 11934567802);
call spInsertForn('Franciscano Cachaça', 1845678937123, 11934567803);
call spInsertForn('Joãozinho Chupeta', 1945678937123, 11934567804);

call spInsertCidade('Rio de Janeiro');
call spInsertCidade('São Carlos');
call spInsertCidade('Campinas');
call spInsertCidade('Franco da Rocha');
call spInsertCidade('Osasco');
call spInsertCidade('Pirituba');
call spInsertCidade('Lapa');
call spInsertCidade('Ponta Grossa');

call spInsertUF('SP');
call spInsertUF('RJ');
call spInsertUF('RS');

call spInsertBairro('Aclimação');
call spInsertBairro('Capão Redondo');
call spInsertBairro('Pirituba');
call spInsertBairro('Liberdade');

call spInsertProduto('12345678910111', 'Rei de Papel Mache', '54.61', '120');
call spInsertProduto('12345678910112', 'Bolinha de Sabão', '100.45', '120');
call spInsertProduto('12345678910113', 'Carro Bate Bate', '44.00', '120');
call spInsertProduto('12345678910114', 'Bola Furada', '10.00', '120');
call spInsertProduto('12345678910115', 'Maçã Laranja', '99.44', '120');
call spInsertProduto('12345678910116', 'Boneco do Hitler', '124.00', '200');
call spInsertProduto('12345678910117', 'Farinha de Suruí', '50.00', '200');
call spInsertProduto('12345678910118', 'Zelador de Cemitério', '24.50', '100');

call spInsertEndereco(12345050, 'Rua da Federal', 'Lapa', 'São Paulo', 'SP');
call spInsertEndereco(12345051, 'Av Brasil', 'Lapa', 'Campinas', 'SP');
call spInsertEndereco(12345052, 'Rua Liberdade', 'Consolação', 'São Paulo', 'SP');
call spInsertEndereco(12345053, 'Av Paulista', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertEndereco(12345054, 'Rua Ximbú', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertEndereco(12345055, 'Rua Piu XI', 'Penha', 'Campina', 'SP');
call spInsertEndereco(12345056, 'Rua Chocolate', 'Aclimação', 'Barra Mansa', 'RJ');
call spInsertEndereco(12345057, 'Rua Pão na Chapa', 'Barra Funda', 'Ponto Grossa', 'RS');

call spInsertCliente('Pimpão', 325, null, 12345051, 12345678911, 12345678, 0, '2000-12-10', 'Av. Brasil', 'Lapa', 'Campinas', 'SP');
call spInsertCliente('Disney Chaplin', 89, 'Ap. 12', 12345053, 12345678912, 12345679, 0, '2001-11-21', 'Av. Paulista', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertCliente('Marciano', 744, null, 12345054, 12345678913, 12345680, 0, '2001-06-01', 'Rua Ximbú', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertCliente('Lança Perfume', 128, null, 12345059, 12345678914, 12345681, 'X', '2004-04-05', 'Rua Veia', 'Jardim Santa Isabel', 'Cuiabá', 'MT');
call spInsertCliente('Remédio Amargo', 2485, null, 12345058, 12345678915, 12345682, 0, '2002-07-15', 'Av. Nova', 'Jardim Santa Isabel', 'Cuiabá', 'MT');

call spInsertCliPJ('Paganada', 12345678912345, 98765432198, 12345051, 'Av. Brasil', 159, null, 'Lapa', 'Campinas', 'SP');
call spInsertCliPJ('Caloteando', 12345678912346, 98765432199, 12345053, 'Av. Paulista', 69, null, 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertCliPJ('Semgrana', 12345678912347, 98765432100, 12345060, 'Rua dos Amores', 189, null, 'Sei Lá', 'Recife', 'PE');
call spInsertCliPJ('Cemreais', 12345678912348, 98765432101, 12345060, 'Rua dos Amores', 5024, 'Sala 23', 'Sei Lá', 'Recife', 'PE');
call spInsertCliPJ('Durango', 12345678912349, 98765432102, 12345060, 'Rua dos Amores', 1254, null, 'Sei Lá', 'Recife', 'PE');

call spInsertCompra(8459, 'Amoroso e Doce', '2018-05-01', 12345678910111, 22.22, 200, 700, 21944.00);
call spInsertCompra(2482, 'Revenda Chico Loco', '2020-04-22', 12345678910112, 40.50, 180, 180, 7290.00);
call spInsertCompra(21563, 'Marcelo Dedal', '2020-07-12', 12345678910113, 3.00, 300, 300, 900.00);
call spInsertCompra(8459, 'Amoroso e Doce', '2020-12-04', 12345678910114, 35.00, 500, 700, 21944.00);
call spInsertCompra(156354, 'Revenda Chico Loco', '2021-11-23', 12345678910115, 54.00, 350, 350, 18900.00);

call spInsertVenda('Pimpão', 12345678910111, 1, null);
call spInsertVenda('Lança Perfume', 12345678910112, 2, null);
call spInsertVenda('Pimpão', 12345678910113, 1, null);

call spInsertNF(359, 'Pimpão', '29/08/2022');
call spInsertNF(360, 'Lança Perfume', '29/08/2022');

call spInsertProduto(12345678910130, 'Camiseta de Poliéster', 35.61, 100);
call spInsertProduto(12345678910131, 'Blusa Frio Moletom', 200.00, 100);
call spInsertProduto(12345678910132, 'Vestido Decote Redondo', 144.00, 50);

call spDeleteProd(12345678910116);
call spDeleteProd(12345678910117);

call spUpdateProd(12345678910111, 'Rei de Papel Mache', 64.50);
call spUpdateProd(12345678910112, 'Bolinha de Sabão', 120.00);
call spUpdateProd(12345678910113, 'Carro Bate Bate', 64.00);

delimiter %%
CREATE PROCEDURE spDeleteProduto (vCodBarras decimal(14,0))
BEGIN
	if exists (SELECT CodBarras FROM tbProduto WHERE CodBarras = vCodBarras) THEN
		DELETE FROM tbProduto WHERE CodBarras = vCodBarras;
    else
		SELECT "O produto inserido não esxiste";
    end if;
end %%

CALL spDeleteProduto("12345678910116");
CALL spDeleteProduto("12345678910117");

SELECT * FROM tbProduto;

delimiter %%
CREATE PROCEDURE spUpdatePtod (vCodBarras decimal(14,0), vNome varchar(200), vValor decimal(6,2))
BEGIN	 

	IF EXISTS (SELECT codBarras from tbProduto where CodBarras = vCodBarras) THEN
		update tbProduto set Nome = vNome, ValorUnitario = vValor where CodBarras = vCodBarras;
    ELSE
    SELECT "O produto não existe";
    END IF;
end %%

CALL spUpdatePtod("12345678910111","Rei de Papel Mache","64.50");
CALL spUpdatePtod("12345678910112","Bolinha de Sabão","120.00");
CALL spUpdatePtod("12345678910113","Carro Bate Bate","64.00");

SELECT * FROM tbProduto;

delimiter $$ 
CREATE PROCEDURE spSelectProduto(vCodBarras decimal(14,0))
BEGIN
	IF EXISTS (SELECT codBarras from tbProduto where CodBarras = vCodBarras) THEN
	select * from tbProduto WHERE CodBarras = vCodBarras;
    else 
    select "o produto não existe";
    end if;
END $$

CALL spSelectProduto();


create table tb_ProdutoHistorico like tbProduto;

ALTER TABLE tb_ProdutoHistorico ADD COLUMN Ocorrencia varchar(20);
ALTER TABLE tb_ProdutoHistorico ADD COLUMN Atualizacao datetime; 


ALTER TABLE tb_ProdutoHistorico drop primary key;
ALTER TABLE tb_ProdutoHistorico add constraint pk_prodHist PRIMARY KEY(CodBarras, Ocorrencia, Atualizacao);

describe tb_ProdutoHistorico;
select * from tb_ProdutoHistorico;

-----------------------------------------------------------------------------------------

-- Ex 19

delimiter &&
CREATE TRIGGER tragInsertProdHist after insert on tbProduto for each row
begin 

	INSERT INTO tb_ProdutoHistorico SET 
    CodBarras = new.CodBarras,
	Qtd = new.Qtd,
	Nome = new.Nome,
	ValorUnitario = new.ValorUnitario,
    Ocorrencia = "novo",
    Atualizacao = current_timestamp();
end; &&

call spInsertProduto("12345678910119","Agua Mineral","1.99","500");
call spInsertProduto("12345678912424","Coreano","1.99","5000");
call spUpdateProd ("12345678912424","Coreana Linda","99.00");
call spInsertProduto("12345678910199","Boneca","21.00","200");
call spUpdateProd ("12345678910199","Boneca Marvel","101.00");

SELECT * FROM tb_ProdutoHistorico;
describe tbProduto;
SELECT * from tbProduto;

call spSelectCliente;

-----------------------------------------------------------------------------------------

-- Ex 20

delimiter &&
CREATE TRIGGER tragUpdatetProdHist after update on tbProduto for each row
begin 

	INSERT INTO tb_ProdutoHistorico SET 
    CodBarras = new.CodBarras,
	Qtd = new.Qtd,
	Nome = new.Nome,
	ValorUnitario = new.ValorUnitario,
    Ocorrencia = "Atualizado",
    Atualizacao = current_timestamp();
    
end; &&

SELECT * from tbVenda; 
describe tbVenda;

UPDATE tbProduto SET ValorUnitario = "2.99" WHERE CodBarras = "12345678910119"; 

-----------------------------------------------------------------------------------------------------------------

-- Ex 21

delimiter &&
CREATE PROCEDURE spSelectAnyProduto() 
begin
	SELECT * from tbProduto;
end &&

call spSelectAnyProduto;

-----------------------------------------------------------------------------------------

-- Ex 22

call spInsertVenda( "Disney Chaplin", "12345678910111", "1", null);

SELECT * from tbVenda; 
SELECT * from tbItemVenda; 

-----------------------------------------------------------------------------------------

-- Ex 23

SELECT * from tbVenda order by NumeroVenda DESC LIMIT 1;


-----------------------------------------------------------------------------------------

-- Ex 24

SELECT * from tbItemVenda order by NumeroVenda DESC LIMIT 1;


-----------------------------------------------------------------------------------------

-- Ex 25


delimiter &&
CREATE PROCEDURE spSelectCLiente(vNome varchar(50)) 

begin

	if exists (SELECT * from tbCliente where NomeCli = vNome) then

	SELECT * from tbCliente where NomeCli = vNome;
    
    else
    SELECT "Não existe o none em questão";

end if;
end &&

call spSelectCLiente("Disney Chaplin");


-----------------------------------------------------------------------------------------

-- Ex 26

delimiter &&
CREATE TRIGGER tragUpdatetProdEstoque after insert on tbItemVenda for each row
begin 

	update tbProduto set Qtd = Qtd  - new.Qtd where CodBarras = new.CodBarras;
    
end; &&



-- (vNumVenda int, vCliente varchar(200), vDataVenda char(10), vCodBarras decimal(14,0), vValorItem decimal(6,2), vQtd int, vTotalVenda int, vNF int)

SELECT * from tbCliente;

select * from tbVenda;

select * from tbProduto;

-----------------------------------------------------------------------------------------

-- Ex 27

call spInsertVenda( "Paganada", "12345678910114", "15", null);
select * from tbVenda;
select * from tbItemVenda;

-----------------------------------------------------------------------------------------

-- Ex 28

call spSelectProduto;


-----------------------------------------------------------------------------------------

-- Ex 29

delimiter &&
CREATE TRIGGER tragUpdatetCompraProd after insert on tbItemCompra for each row
begin 

	update tbProduto set Qtd = Qtd  + new.Qtd where CodBarras = new.CodBarras;
    
end; &&


-----------------------------------------------------------------------------------------

-- Ex 30

call spInsertCompra(10548, 'Amoroso e Doce', '2022-09-10', 12345678910111, 40.00, 100, 100, 4000.00);


-----------------------------------------------------------------------------------------

-- Ex 31

call spSelectAnyProduto;

-- 4°bimestre
-- Ex 32

select * from tbCliente inner join tbClientePF on tbCliente.Id = tbClientePF.IdCliente;
-- ex 33

select * from tbCliente inner join tbClientePJ on tbCliente.Id = tbClientePJ.IdCliente;
-- ex 34

select Id, NomeCli, Cnpj, Ie, IdCliente from tbCliente inner join tbClientePJ on tbCliente.Id = tbClientePJ.IdCliente;

-- ex 35
select Id'codigo', NomeCli'nome', CPF, RG, Nasc'data de nascimento'  from tbCliente inner join tbClientePF on tbCliente.Id = tbClientePF.IdCliente;

-- ex 36

select Id, NomeCli, NumEnd, CompEnd, CEPCli, CNPJ, IE, IdCliente,Logradouro,IdBairro,IdCidade,IdUF,CEP 
from tbCliente inner join tbClientePJ on tbCliente.Id = tbClientePJ.IdCliente inner join  tbEndereco  on tbCliente.CEPCli = tbEndereco.CEP;

-- ex 37

select Id, NomeCli, CEPCli, Logradouro, NumEnd,CompEnd, Bairro, Cidade, UF 
from tbCliente inner join tbClientePJ on tbCliente.Id = tbClientePJ.IdCliente inner join  tbEndereco on tbCliente.CEPCli = tbEndereco.CEP inner join tbUF on tbEndereco.IdUF = tbUF.IdUF
inner join tbCidade on tbEndereco.IdCidade = tbCidade.IdCidade inner join tbBairro on tbEndereco.IdBairro = tbBairro.IdBairro;

-- ex 38

delimiter $$
create procedure spSelectClientePFisicaID (vID int)
begin
select Id'codigo', NomeCli'nome', CPF, Rg, RgDig'digito', Nasc'data de nascimento', Cep, Logradouro, NumEnd'numero', CompEnd'complemento', Bairro, Cidade, UF 
from tbCliente inner join tbClientePF on tbCliente.Id = tbClientePF.IdCliente inner join  tbEndereco  on tbCliente.CEPCli = tbEndereco.CEP inner join tbUF on tbEndereco.IdUF = tbUF.IdUF 
inner join tbCidade on tbEndereco.IdCidade = tbCidade.IdCidade inner join tbBairro on tbEndereco.IdBairro = tbBairro.IdBairro where Id = vID;
end
$$


call spSelectClientePFisicaID(2);

call spSelectClientePFisicaID(5)


-- ex 39 
select tbProduto.CodBarras, Nome, ValorUnitario, tbProduto.Qtd, tbItemVenda.Qtd, ValorItem,tbItemVenda.CodBarras, NumeroVenda  from tbProduto left join tbItemVenda on tbProduto.Codbarras = tbItemVenda.CodBarras;

-- ex 40 
select * from tbCompra right join tbFornecedor on tbCompra.Cod_Fornecedor = tbFornecedor.codigo;

-- ex 41
select Codigo, Cnpj, Nome, Telefone from tbCompra right join tbFornecedor on tbFornecedor.Codigo = tbCompra.Cod_Fornecedor where  Cod_Fornecedor is null

-- ex 42
select id, NomeCli, DataVenda , tbProduto.CodBarras, Nome, ValorUnitario'ValorItem' from tbCliente left join tbVenda on tbCliente.id = tbVenda.IdCliente 
left join tbItemVenda on tbVenda.NumeroVenda = tbItemVenda.NumeroVenda left join tbProduto on tbItemvenda.CodBarras = tbProduto.CodBarras where tbProduto.CodBarras is not null order by NomeCli

-- ex 43
select * from tbBairro left join tbEndereco on tbBairro.IdBairro = tbEndereco.IdBairro left join tbCliente on tbEndereco.CEP = tbCliente.CEPCli 
left join tbVenda on tbVenda.IdCliente = tbCliente.Id 
 group by tbBairro.Bairro

 

-- selecionando tabelas
describe tbCliente;
describe tbClientePF;
select * from tbClientePJ;
select * from tbEndereco;
select * from tbUF;
select * from tbCidade;
select * from tbBairro;
select * from tbProduto;
select * from tbFornecedor;
select * from tbItemCompra;
select * from tbCompra;
select * from tbVenda;
select * from tbItemVenda;
select * from tbNotaFiscal;




-- extra 
call spInsertVenda( "Disney Chaplin", "12345678910115", "35", null);