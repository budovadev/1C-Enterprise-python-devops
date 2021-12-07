USE [master]
GO
/****** Объект:  StoredProcedure [dbo].[BackupCopyDB]    Дата сценария: 03/04/2014 09:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BackupCopyDB] 	
 
	-- имя бд,которую будем бэкапить
	@db nvarchar(100)
 
	-- путь куда будет делаться наш файл бэкапа	
	-- если делаем бэкап локально,то достаточно указать путь "буква диска:\имя папки\"
	-- иначе пишем полный путь "\\имя сервера\путь до папки". Необходимо,чтобы у учетки SQL Agent'a  был доступ в указанную папку
	,@b_path nvarchar(100) = N'D:\'
 
	-- путь куда будет скопирован файл бэкапа 
	-- пишем полный путь "\\имя сервера\путь до папки". Необходимо,чтобы у учетки SQL Agent'a  был доступ в указанную папку
	,@c_path nvarchar(100) =N'S'
 
	-- email адрес, на который будут присылаться уведомления выполнения хранимой процедуры
	,@email nvarchar(100) = N'event.messages@ctmol.ru'
 
	-- флаг,если true то на почту будут приходить уведомления после каждого выполненного шага в хранимке
	-- иначе прийдет только уведомление об окончании выполнения хранимой процедуры
	,@alert bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-----------------------------------------------------
 
	-- путь до бэкапа
	declare @storegeplace varchar(260)
 
	-- перемення для команды cmd
	declare @var varchar(260)
 
	-- гарантия почти уникальности имени файла
	declare @seckey nvarchar(12)
 
	-- текущая дата формата ггггммдд
	declare @a nvarchar(8) 
 
	-- текущее время чч:мм
	declare @b nvarchar(5)
 
	-- два правых символа от @b
	declare @c nvarchar(2)
 
	-- два левых символа от @b
	declare @d nvarchar(2)
 
	-- flag
	declare @flag bit
 
	-- alert	
	declare @alert_desc nvarchar(100)	
 
	-----------------------------------------------------
	set @a = (select CONVERT(nvarchar(8), GETDATE(), 112)) 
	set @b = (select CONVERT(nvarchar(5), GETDATE(), 108)) 
	set @c = RIGHT(@b,2)
	set @d = LEFT(@b,2)
	-- получаем значение seckey
	set @seckey = @a +@d+@c
 
	-- указываем полный путь до файла бэкапа
	set @storegeplace = @b_path+@db+'_'+@seckey+'.bak' 
 
	-- указываем параметры для команды в cmd
	set @var = 'copy '+ @storegeplace + ' '+@c_path+@db + '_'+@seckey+'.bak'
 
	-- обнуляем flag
	set @flag = 0
 
	-----------------------------------------------------
 
	-- проверка входных параметров
	if (len(@db)<=0)
		begin
			print 'не указано имя базы данных'
			print ' '
		end
		else
 
			BEGIN
 
						print 'бэкап будет делаться сюда --> ' + @storegeplace
						print ' '
 
						-- alert #1
						--if (@alert = 1)
						--		begin
						--					set @alert_desc = 'бэкап будет делаться сюда --> ' + @storegeplace + ' ('+ CONVERT(nvarchar(20), GETDATE(), 113)+')'
						--					EXECUTE msdb.dbo.sp_send_dbmail
						--						@profile_name  = 'atrans',        
						--						@recipients  = @email,
						--						@subject  = 'OK.Хранимая Процедура BackupCopyDB'
						--						,@body = @alert_desc
						--		end
						-- end alert #1
 
						begin try
								BACKUP DATABASE @db
								TO  DISK = @storegeplace
								WITH NOFORMAT, NOINIT,  NAME = @db, SKIP, NOREWIND, NOUNLOAD,  STATS = 10
								print ' '
								print 'бэкап готов '
 
								-- alert #2
							--if (@alert = 1)
							--	begin
							--		set @alert_desc = 'бэкап "'+@db+'" готов.'+' ('+CONVERT(nvarchar(20), GETDATE(), 113)+')'
							--		EXECUTE msdb.dbo.sp_send_dbmail
							--		@profile_name  = 'atrans',        
							--		@recipients  = @email,
							--		@subject  = 'OK.Хранимая Процедура BackupCopyDB'
							--		,@body = @alert_desc
							--	end
							-- end alert #2
 
							set @flag = 1
						end try
						BEGIN CATCH
							SELECT
								ERROR_NUMBER() AS ErrorNumber,
								ERROR_SEVERITY() AS ErrorSeverity,
								ERROR_STATE() AS ErrorState,
								ERROR_PROCEDURE() AS ErrorProcedure,
								ERROR_LINE() AS ErrorLine,
								ERROR_MESSAGE() AS ErrorMessage;
							print ' '
							print 'что-то пошло не так и бэкап не сделался'
							set @flag = 0
							--EXECUTE msdb.dbo.sp_send_dbmail
							--	   @profile_name  = 'atrans',        
							--	   @recipients  = @email,
							--	   @subject  = 'ERROR.Хранимая Процедура BackupCopyDB'
						END CATCH;	
 
 
						--if(len(@c_path)>1)						
						--	begin
 
						--if (@flag = 1)
						--		begin
						--			begin try
						--				print ' '
						--				print 'бэкап копируется сюда --> '+@c_path+@db + '_'+@seckey+'.bak'
						--				print 'на почтовый адрес ' + @email + ' будет отправлено уведомление по окончанию копирования. enjoy :)'
 
										-- alert #3
						--				if (@alert = 1)
						--					begin
						--						set @alert_desc = 'бэкап копируется сюда --> '+@c_path+@db + '_'+@seckey+'.bak'+' ('+CONVERT(nvarchar(20), GETDATE(), 113)+')'
						--						EXECUTE msdb.dbo.sp_send_dbmail
						--						@profile_name  = 'atrans',        
						--						@recipients  = @email,
						--						@subject  = 'OK.Хранимая Процедура BackupCopyDB'
						--						,@body = @alert_desc
						--					end
										-- end alert #3
 
						--				EXEC master..xp_cmdshell @var
 
						--				set @alert_desc = 'OK.Хранимая Процедура BackupCopyDB выполнена'+' ('+CONVERT(nvarchar(20), GETDATE(), 113)+')'
						--				EXECUTE msdb.dbo.sp_send_dbmail
							--			   @profile_name  = 'atrans',        
						--				   @recipients  = @email,
						--				   @subject  = 'OK.Хранимая Процедура BackupCopyDB'
						--					,@body = @alert_desc 
						--			end try	
						--			BEGIN CATCH
						--				SELECT
						--					ERROR_NUMBER() AS ErrorNumber,
						--					ERROR_SEVERITY() AS ErrorSeverity,
						--					ERROR_STATE() AS ErrorState,
						--					ERROR_PROCEDURE() AS ErrorProcedure,
						--					ERROR_LINE() AS ErrorLine,
						--					ERROR_MESSAGE() AS ErrorMessage;
						--				print ' '
						--				print 'что-то пошло не так и бэкап не скопировался'
						--				EXECUTE msdb.dbo.sp_send_dbmail
						--				   @profile_name  = 'atrans',        
						--				   @recipients  = @email,
						--				   @subject  = 'ERROR.Хранимая Процедура BackupCopyDB'
						--			END CATCH;
						--		end	
						--	end	
		END;
 
END