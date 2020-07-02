 SET IDENTITY_INSERT [dbo].[Skill] ON;

  INSERT INTO [dbo].[Skill] ([SkillID], [SkillName])
  SELECT [SkillID], [SkillName]
  FROM (
	SELECT 1 AS [SkillID], 'C#' AS [SkillName] UNION ALL
	SELECT 2 AS [SkillID], 'Java' AS [SkillName] UNION ALL
	SELECT 3 AS [SkillID], 'C' AS [SkillName] UNION ALL
	SELECT 4 AS [SkillID], 'C++' AS [SkillName] UNION ALL
	SELECT 5 AS [SkillID], 'T-SQL' AS [SkillName] UNION ALL
	SELECT 6 AS [SkillID], 'SSIS' AS [SkillName] UNION ALL
	SELECT 7 AS [SkillID], 'SSAS' AS [SkillName] UNION ALL
	SELECT 8 AS [SkillID], 'SSRS' AS [SkillName] UNION ALL
	SELECT 9 AS [SkillID], 'SSMS' AS [SkillName] UNION ALL
	SELECT 10 AS [SkillID], 'Visual Studio' AS [SkillName] UNION ALL
	--...
	SELECT 100 AS [SkillID], 'Notepad++' AS [SkillName]
  ) AS tbl;

  SET IDENTITY_INSERT [dbo].[Skill] OFF;
