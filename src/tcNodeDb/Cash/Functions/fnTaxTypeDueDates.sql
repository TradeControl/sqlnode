CREATE   FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
	DECLARE @MonthNumber smallint
			, @TaxMonth smallint
			, @MonthInterval smallint
			, @StartOn datetime
	
		SELECT 
			@TaxMonth = MonthNumber, 
			@MonthInterval = CASE RecurrenceCode
								WHEN 0 THEN 1
								WHEN 1 THEN 1
								WHEN 2 THEN 3
								WHEN 3 THEN 6
								WHEN 4 THEN 12
							END
		FROM Cash.tbTaxType
		WHERE TaxTypeCode = @TaxTypeCode
				
		IF @TaxTypeCode = 0
			GOTO CorporationTax;
		ELSE
			GOTO DefaultTaxType;

	Finalise:

		UPDATE @tbDueDate
		SET PayOn = DATEADD(DAY, (SELECT OffsetDays FROM Cash.tbTaxType WHERE TaxTypeCode = @TaxTypeCode), PayOn)

		RETURN;

	DefaultTaxType:
	
		SET @MonthNumber = @TaxMonth

		SELECT   @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (MonthNumber = @MonthNumber)

		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayOn, LAG(PayOn) OVER (ORDER BY PayOn) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn;

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate);

		GOTO Finalise

	CorporationTax:

		SELECT   @StartOn = StartOn, @MonthNumber = MonthNumber
		FROM         App.tbYearPeriod
		WHERE StartOn = (SELECT MIN(StartOn) FROM App.tbYearPeriod)

		INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)

		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayFrom, LEAD(PayFrom) OVER (ORDER BY PayFrom) AS PayTo
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayTo
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayFrom = dd.PayFrom;

		DELETE FROM @tbDueDate WHERE PayTo IS NULL;

		SET @StartOn = (SELECT MIN(PayFrom) FROM @tbDueDate)		
		SELECT @MonthNumber = DATEDIFF(MONTH, @StartOn, MIN(StartOn)) FROM App.tbYearPeriod
		WHERE MonthNumber = @TaxMonth AND StartOn >= @StartOn

		UPDATE @tbDueDate
		SET PayOn = DATEADD(MONTH, @MonthNumber, PayTo)

		GOTO Finalise
	RETURN	
	END
