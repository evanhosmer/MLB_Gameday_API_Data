-- The following SQL script will compute the slash lines for every batter in 2016

SELECT t1.batter_id, t1.player_name, t1.AB, ((t1.singles + t1.doubles + t1.triples + t1.homers) / t1.AB) as avg,
((t1.singles + (2 * t1.doubles) + (3 * t1.triples) + (4 * t1.homers)) / t1.AB) as SLG,
(((t1.singles+t1.doubles+t1.triples+t1.homers) + t2.walks + t2.hbp) / (t1.AB + t2.walks + t2.hbp + t2.sac_flys)) as OBP FROM
(SELECT pbp_play_by_play.batter_id,
CONCAT(player_master.name_first,' ', player_master.name_last) as player_name,
COUNT(*) as AB,
SUM(CASE WHEN pbp_play_by_play.event_type = 'single' THEN 1 ELSE 0 END) as singles,
SUM(CASE WHEN pbp_play_by_play.event_type = 'double' THEN 1 ELSE 0 END) as doubles,
SUM(CASE WHEN pbp_play_by_play.event_type = 'triple' THEN 1 ELSE 0 END) as triples,
SUM(CASE WHEN pbp_play_by_play.event_type = 'home_run' THEN 1 ELSE 0 END) as homers
FROM pbp_play_by_play
JOIN player_master
ON player_master.player_id = pbp_play_by_play.batter_id
WHERE pbp_play_by_play.description LIKE CONCAT(CONCAT(player_master.name_first,' ', player_master.name_last), '%')
AND pbp_play_by_play.rec_type = 'play_by_play'
AND pbp_play_by_play.description NOT LIKE '%walks%'
AND pbp_play_by_play.event_type <> 'hit_by_pitch'
AND pbp_play_by_play.event_type<> 'sac_fly'
AND pbp_play_by_play.event_type <> 'sac_bunt'
AND pbp_play_by_play.event_type <> 'batter_interference'
GROUP BY pbp_play_by_play.batter_id) AS t1
INNER JOIN
(SELECT
  batter_id,
  SUM(CASE WHEN pbp_play_by_play.event_type = 'sac_fly' THEN 1 ELSE 0 END) as sac_flys,
  SUM(CASE WHEN pbp_play_by_play.event_type = 'hit_by_pitch' THEN 1 ELSE 0 END) as hbp,
  SUM(CASE WHEN pbp_play_by_play.event_type = 'walk' THEN 1 ELSE 0 END) as walks
 FROM pbp_play_by_play
 GROUP BY pbp_play_by_play.batter_id) AS t2
 ON
 t1.batter_id = t2.batter_id;
