CREATE OR REPLACE PACKAGE PK1 IS
 PROCEDURE xLis (xfamilia IN Articulos.cArtFml%TYPE);
END;
CREATE OR REPLACE PACKAGE BODY PK1 IS
 
     /* PROCEDIMIENTO INSERTAR CENTRO */
    
    PROCEDURE insertar_centro(
      p_nombre in centros.nombre%type, 
      p_provincia in CENTROS.PROVINCIA%type
    )
    IS
      v_nombre CENTROS.NOMBRE%type;
      e_found exception;
    BEGIN
      select nombre
      into v_nombre
      from centros 
      where nombre=p_nombre;
      
      if sql%found
        then
          raise e_found;
      end if;    
    EXCEPTION
      when e_found then
        DBMS_OUTPUT.PUT_LINE('El centro que intenta insertar ya existe');
      when no_data_found then
        insert into centros (nombre, provincia) values (p_nombre, p_provincia);
    END;
        
    DECLARE
      v_nombre CENTROS.NOMBRE%type:='centro1';
    BEGIN
      insertar_centro(v_nombre,'gipuzkoa');
      DBMS_OUTPUT.PUT_LINE(v_nombre);
    END;
    
    /* PROCEDIMIENTO VISUALIZAR LISTA CENTRO */
    
    PROCEDURE visualizar_lista_centro
    IS
      cursor c1 is
        select *
        from centros;
      
      v_reg c1%rowtype;  
    BEGIN
      open c1;
      
      fetch c1 into v_reg;
      while c1%found loop
        DBMS_OUTPUT.PUT_LINE(v_reg.id || ' ' || v_reg.nombre || ' ' || v_reg.calle || ' ' || v_reg.numero || ' ' || v_reg.cp || ' ' || v_reg.ciudad || ' ' || v_reg.provincia || ' ' || v_reg.telefono);
        fetch c1 into v_reg;
      end loop;
      
      close c1;
    END visualizar_lista_centro;
    
    execute visualizar_lista_centro;
    
    select * from centros;
    
      --BORRAR CENTRO Y TRANSFERIR LOS TRABAJADORES A OTRO CENTRO
    
    
    PROCEDURE borrar_centro(
      v_fuente IN CENTROS.ID%TYPE, v_destino IN CENTROS.ID%TYPE
    )AS
        E_FALLO_FUENTE EXCEPTION;
        E_FALLO_DESTINO EXCEPTION;
        E_FALLO_TRANSFERIR EXCEPTION;
        V_TEMP CENTROS.ID%TYPE;
      BEGIN
        SELECT ID INTO V_TEMP FROM CENTROS WHERE ID = v_fuente;
        IF SQL%NOTFOUND THEN
          RAISE E_FALLO_FUENTE;
        ELSE
          SELECT ID into V_TEMP FROM CENTROS WHERE ID = v_destino;
          IF SQL%NOTFOUND THEN
            RAISE E_FALLO_DESTINO;
          ELSE
            UPDATE TRABAJADOR SET IDCENTRO=v_destino WHERE IDCENTRO = v_fuente;
            IF SQL%NOTFOUND THEN
              RAISE E_FALLO_TRANSFERIR; 
            END IF;
          END IF;
        END IF;
      EXCEPTION
        WHEN E_FALLO_FUENTE THEN
          RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro a borrar.');
        WHEN E_FALLO_DESTINO THEN
          RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro de destino.');
        when E_FALLO_TRANSFERIR THEN
          RAISE_APPLICATION_ERROR(-20112,'Error al transferir los trabajadores.');
      END;
              
              desc centros;
      --BUSCAR CENTRO POR NOMBRE
    
    PROCEDURE buscar_centro_por_nombre(
      v_nCentro IN CENTROS.NOMBRE%TYPE, v_idCentro OUT CENTROS.ID%TYPE
    )AS
        E_CENTRO_ERRONEO EXCEPTION;
      BEGIN
        SELECT ID INTO v_idCentro FROM CENTROS WHERE UPPER(NOMBRE) LIKE UPPER(V_NCENTRO);
        IF SQL%NOTFOUND THEN
          RAISE E_CENTRO_ERRONEO;
        END IF;
      EXCEPTION
        WHEN E_CENTRO_ERRONEO THEN
          RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro.');
      END;
      
      --CAMBIAR PROVINCIA
      
      PROCEDURE cambiar_provincia(
      p_idCentro NUMBER,
      p_provincia VARCHAR2)
     IS
      e_idCentro_inexistente EXCEPTION;
     -- BLOQUE PRINCIPAL
     BEGIN
     -- BLOQUE Para comprobar CENTRO repetido(Puede disparar NO_DATA_FOUND)
        DECLARE
        v_idCentro centro.idCentro%TYPE; 
       -- e_idCentro_inexistente se propaga;
      BEGIN
        SELECT idCentro INTO v_idCentro FROM centro
        WHERE idCentro = p_idCentro);
        -- Enviamos al bloque principal la excepción definida por nosotros e_idCentro_inexistente
          IF SQL%NOTFOUND THEN
            RAISE e_idCentro_inexistente;  
          END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --Si se dispara esta excepción hay error, ese p_idCentro no es correcto
          RAISE_APPLICATION_ERROR ('-20002','Error: '||sqlerrm);
        WHEN TOO_MANY_ROWS THEN
          NULL; 
      END;		
      --	Fin del bloque de comprobación de id_Centro inexistente 
    
    -- Inserta Centro 
        
      UPDATE centro SET provincia = p_provincia WHERE centro.idCentro = p_idCentro
      -- Comprobar
      IF SQL%FOUND
      THEN
        COMMIT;
      END IF;
     EXCEPTION
      WHEN e_idCentro_inexistente THEN
        RAISE_APPLICATION_ERROR ('-20001','Err. id de Centro inexistente');
      WHEN OTHERS THEN   
        RAISE_APPLICATION_ERROR ('-20003','Error: '||sqlerrm);
    
    END cambiar_provincia;
 
END;



/* PROCEDIMIENTO INSERTAR CENTRO */

CREATE OR REPLACE PROCEDURE insertar_centro(
  p_nombre in centros.nombre%type, 
  p_provincia in CENTROS.PROVINCIA%type
)
IS
  v_nombre CENTROS.NOMBRE%type;
  e_found exception;
BEGIN
  select nombre
  into v_nombre
  from centros 
  where nombre=p_nombre;
  
  if sql%found
    then
      raise e_found;
  end if;    
EXCEPTION
  when e_found then
    DBMS_OUTPUT.PUT_LINE('El centro que intenta insertar ya existe');
  when no_data_found then
    insert into centros (nombre, provincia) values (p_nombre, p_provincia);
END;

select * from centros;

execute insertar_centro('centro1','gipuzkoa');

DECLARE
  v_nombre CENTROS.NOMBRE%type:='centro1';
BEGIN
  insertar_centro(v_nombre,'gipuzkoa');
  DBMS_OUTPUT.PUT_LINE(v_nombre);
END;

/* PROCEDIMIENTO VISUALIZAR LISTA CENTRO */

CREATE OR REPLACE PROCEDURE visualizar_lista_centro
IS
  cursor c1 is
    select *
    from centros;
  
  v_reg c1%rowtype;  
BEGIN
  open c1;
  
  fetch c1 into v_reg;
  while c1%found loop
    DBMS_OUTPUT.PUT_LINE(v_reg.id || ' ' || v_reg.nombre || ' ' || v_reg.calle || ' ' || v_reg.numero || ' ' || v_reg.cp || ' ' || v_reg.ciudad || ' ' || v_reg.provincia || ' ' || v_reg.telefono);
    fetch c1 into v_reg;
  end loop;
  
  close c1;
END visualizar_lista_centro;

execute visualizar_lista_centro;

select * from centros;

  --BORRAR CENTRO Y TRANSFERIR LOS TRABAJADORES A OTRO CENTRO


CREATE OR REPLACE PROCEDURE borrar_centro(
  v_fuente IN CENTROS.ID%TYPE, v_destino IN CENTROS.ID%TYPE
)AS
    E_FALLO_FUENTE EXCEPTION;
    E_FALLO_DESTINO EXCEPTION;
    E_FALLO_TRANSFERIR EXCEPTION;
    V_TEMP CENTROS.ID%TYPE;
  BEGIN
    SELECT ID INTO V_TEMP FROM CENTROS WHERE ID = v_fuente;
    IF SQL%NOTFOUND THEN
      RAISE E_FALLO_FUENTE;
    ELSE
      SELECT ID into V_TEMP FROM CENTROS WHERE ID = v_destino;
      IF SQL%NOTFOUND THEN
        RAISE E_FALLO_DESTINO;
      ELSE
        UPDATE TRABAJADOR SET IDCENTRO=v_destino WHERE IDCENTRO = v_fuente;
        IF SQL%NOTFOUND THEN
          RAISE E_FALLO_TRANSFERIR; 
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN E_FALLO_FUENTE THEN
      RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro a borrar.');
    WHEN E_FALLO_DESTINO THEN
      RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro de destino.');
    when E_FALLO_TRANSFERIR THEN
      RAISE_APPLICATION_ERROR(-20112,'Error al transferir los trabajadores.');
  END;
          
          desc centros;
  --BUSCAR CENTRO POR NOMBRE

CREATE OR REPLACE PROCEDURE buscar_centro_por_nombre(
  v_nCentro IN CENTROS.NOMBRE%TYPE, v_idCentro OUT CENTROS.ID%TYPE
)AS
    E_CENTRO_ERRONEO EXCEPTION;
  BEGIN
    SELECT ID INTO v_idCentro FROM CENTROS WHERE UPPER(NOMBRE) LIKE UPPER(V_NCENTRO);
    IF SQL%NOTFOUND THEN
      RAISE E_CENTRO_ERRONEO;
    END IF;
  EXCEPTION
    WHEN E_CENTRO_ERRONEO THEN
      RAISE_APPLICATION_ERROR(-20111,'No se ha encontrado el centro.');
  END;
  
  --CAMBIAR PROVINCIA
  
  CREATE OR REPLACE PROCEDURE cambiar_provincia(
	p_idCentro NUMBER,
	p_provincia VARCHAR2)
 IS
	e_idCentro_inexistente EXCEPTION;
 -- BLOQUE PRINCIPAL
 BEGIN
 -- BLOQUE Para comprobar CENTRO repetido(Puede disparar NO_DATA_FOUND)
  	DECLARE
	  v_idCentro centro.idCentro%TYPE; 
	 -- e_idCentro_inexistente se propaga;
	BEGIN
	  SELECT idCentro INTO v_idCentro FROM centro
		WHERE idCentro = p_idCentro);
    -- Enviamos al bloque principal la excepción definida por nosotros e_idCentro_inexistente
      IF SQL%NOTFOUND THEN
	      RAISE e_idCentro_inexistente;  
      END IF;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  --Si se dispara esta excepción hay error, ese p_idCentro no es correcto
	    RAISE_APPLICATION_ERROR ('-20002','Error: '||sqlerrm);
	  WHEN TOO_MANY_ROWS THEN
	    NULL; 
	END;		
  --	Fin del bloque de comprobación de id_Centro inexistente 

-- Inserta Centro 
    
	UPDATE centro SET provincia = p_provincia WHERE centro.idCentro = p_idCentro
	-- Comprobar
	IF SQL%FOUND
	THEN
		COMMIT;
	END IF;
 EXCEPTION
  WHEN e_idCentro_inexistente THEN
    RAISE_APPLICATION_ERROR ('-20001','Err. id de Centro inexistente');
  WHEN OTHERS THEN   
    RAISE_APPLICATION_ERROR ('-20003','Error: '||sqlerrm);

END cambiar_provincia;