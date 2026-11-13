-- Retired commissioning state was replaced by readiness derived from the
-- active Published/Submitted Category Tree pointer. Remove the legacy
-- dependency before the options table loses its redundant flag column.
DROP PROCEDURE IF EXISTS App.proc_Initialised;
