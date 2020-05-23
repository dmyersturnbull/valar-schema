#Create v_experiments
CREATE VIEW v_experiments as 
select e.id, e.name as experiment, e.description, username as creator, s.name as project, b.name as battery, tp.name as template_plate, trp.name as transfer_plate, default_acclimation_sec, e.notes, e.active, 
substring_index(e.created, ' ', 1) as date, substring_index(b.created, ' ', -1) as time 
FROM experiments as e LEFT OUTER JOIN users as u on e.creator_id = u.id LEFT OUTER JOIN superprojects as s on e.project_id = s.id LEFT OUTER JOIN batteries as b on e.battery_id = b.id 
LEFT OUTER JOIN template_plates as tp on e.template_plate_id = tp.id LEFT OUTER JOIN transfer_plates as trp on e.transfer_plate_id = trp.id;

#Create v_annotations 
#all the well_ids are null so dont join on wells
CREATE VIEW v_annotations as 
select a.id, a.name, a.value, a.level, r.name as run, s.lookup_hash as submission, well_id, assays.name as assay, u.username as annotator, a.description, 
substring_index(a.created, ' ', 1) as date, substring_index(a.created, ' ', -1) as time 
FROM annotations as a LEFT OUTER JOIN runs as r on a.run_id = r.id LEFT OUTER JOIN submissions as s on a.submission_id = s.id LEFT OUTER JOIN assays on a.assay_id = assays.id 
LEFT OUTER JOIN users as u on a.annotator_id = u.id; 

#Create v_assays_in_bat order by battery and assay position start
CREATE VIEW v_assays_in_bat as
select b.id, b.name as battery, b.description, b.length as battery_length, u.username as author, a.name as assay, ap.start, a.length as length, ta.id as template_assay_id, tsf.range_expression, tsf.value_expression, substring_index(b.created, ' ', 1) as date, substring_index(b.created, ' ', -1) as time
from batteries as b LEFT OUTER JOIN assay_positions as ap on b.id = ap.battery_id LEFT OUTER JOIN users as u on b.author_id = u.id LEFT OUTER JOIN assays as a on ap.assay_id = a.id 
LEFT OUTER JOIN template_assays as ta on a.template_assay_id = ta.id LEFT OUTER JOIN template_stimulus_frames as tsf on tsf.template_assay_id = ta.id ORDER BY b.id, ap.start;

#Create v_runs_well_treatments
#Left outer Join on wells to account for all wells and 
CREATE VIEW v_runs_well_treatments as 
select w.id as well_id,r.name as run, w.well_index, b.tag, v_cl.name as compound, v_cl.ref_name , b.amount, b.concentration_millimolar, b.solvent_id, b.notes, b.suspicious, wt.micromolar_dose
FROM wells as w LEFT OUTER JOIN well_treatments as wt on w.id = wt.well_id LEFT OUTER JOIN batches as b on wt.batch_id = b.id LEFT OUTER JOIN v_compound_labels as v_cl on b.compound_id = v_cl.compound_id 
LEFT OUTER JOIN runs as r on w.run_id = r.id;

#Create v_batteries
CREATE VIEW v_batteries as 
select b.id, b.name, b.description, b.length, u.username as author, b.notes, substring_index(b.created, ' ', 1) as date, substring_index(b.created, ' ', -1) as time 
FROM batteries as b LEFT OUTER JOIN users as u on b.author_id = u.id;

#Create v_carp_projects
CREATE VIEW v_carp_projects as 
select cp.id, cp.name, cp.description, cpt.name as project_type, cp_2.name as ancestor, u.username as owner, substring_index(cp.modified, ' ', 1) as date_modified, substring_index(cp.modified, ' ', -1) as time_modified,
substring_index(cp.created, ' ', 1) as date_created, substring_index(cp.created, ' ', -1) as time_created
FROM carp_projects as cp LEFT OUTER JOIN carp_project_types as cpt on cp.project_type_id = cpt.id LEFT OUTER JOIN carp_projects as cp_2 on cp.ancestor_id = cp_2.id LEFT OUTER JOIN users as u on cp.owner_id = u.id;

#Create v_carp_scans
CREATE VIEW v_carp_scans as 
select cs.id, ct.internal_id as tank_internal_id, cs.scan_type, cs.scan_value, u.username as person_scanned, substring_index(cs.datetime_scanned, ' ', 1) as date_scanned, substring_index(cs.datetime_scanned, ' ', -1) as time_scanned,
substring_index(cs.created, ' ', 1) as date_created, substring_index(cs.created, ' ', -1) as time_created
FROM carp_scans as cs LEFT OUTER JOIN carp_tanks as ct on cs.tank_id = ct.id LEFT OUTER JOIN users as u on cs.person_scanned_id = u.id;

#Create v_carp_tanks
#I use two subqueries towards the end: first one corresponds to v_carp_tank_types and second subquery corresponds to carp_recent_tank_task.
CREATE VIEW v_carp_tanks as 
select ct.id, ct.internal_id as tank, cp.name as project, gv.id as variant_id, gv.mother_id as mother_id, gv.father_id as father_id, ctt.name as tank_type, ctt.project_type as project_type, crtt.task as current_task, crtt.date_created as date_task_created, crtt.time_created as time_task_created,  ct.birthdate, ct.alive, ct.notes, gv.name as variant,
substring_index(ct.created, ' ', 1) as date_created, substring_index(ct.created, ' ', -1) as time_created
FROM carp_tanks as ct LEFT OUTER JOIN carp_projects as cp on ct.project_id = cp.id LEFT OUTER JOIN genetic_variants as gv on ct.variant_id = gv.id LEFT OUTER JOIN (select ctt.id, ctt.name, cpp.name as project_type, ctt.description, substring_index(ctt.created, ' ', 1) as date_created, substring_index(ctt.created, ' ', -1) as time_created
FROM carp_tank_types as ctt LEFT OUTER JOIN carp_project_types as cpp on ctt.project_type_id = cpp.id) as ctt on ct.tank_type_id = ctt.id LEFT OUTER JOIN (select ctt.id, ctn.internal_id as tank, cta.name as task, ctt.notes, substring_index(ctt.created, ' ', 1) as date_created, substring_index(ctt.created, ' ', -1) as time_created
FROM carp_tank_tasks as ctt LEFT OUTER JOIN carp_tanks as ctn on ctt.tank_id = ctn.id LEFT OUTER JOIN carp_tasks as cta on ctt.task_id = cta.id 
WHERE ctt.created = (select MAX(ctt2.created) FROM carp_tank_tasks as ctt2 WHERE ctt.tank_id = ctt2.tank_id)) as crtt on ct.internal_id = crtt.tank;

#Create v_carp_recent_tank_tasks ONLY INCLUDES carp tanks with tasks 
CREATE VIEW v_carp_recent_tank_task as
select ctt.id, ctn.internal_id as tank, cta.name as task, ctt.notes, substring_index(ctt.created, ' ', 1) as date_created, substring_index(ctt.created, ' ', -1) as time_created
FROM carp_tank_tasks as ctt LEFT OUTER JOIN carp_tanks as ctn on ctt.tank_id = ctn.id LEFT OUTER JOIN carp_tasks as cta on ctt.task_id = cta.id 
WHERE ctt.created = (select MAX(ctt2.created) FROM carp_tank_tasks as ctt2 WHERE ctt.tank_id = ctt2.tank_id);

#Create v_carp_tank_types
CREATE VIEW v_carp_tank_types as 
select ctt.id, ctt.name, cpp.name as project_type, ctt.description, substring_index(ctt.created, ' ', 1) as date_created, substring_index(ctt.created, ' ', -1) as time_created
FROM carp_tank_types as ctt LEFT OUTER JOIN carp_project_types as cpp on ctt.project_type_id = cpp.id;

#Create v_compound_labels
#Creates views for compound labels, choosing the first match based on the following order (86, 1, 3, 10, 17, 40, 43, 44, 45, every other ref_id)
CREATE VIEW v_compound_labels as 
select c_label.compound_id, c_label.name, c.inchikey, refs.name as ref_name, c_label.date_created, c_label.time_created
FROM (select c_grp.compound_id, c_grp.name, c_grp.ref_id, substring_index(c_grp.created, ' ', 1) as date_created, substring_index(c_grp.created, ' ', -1) as time_created
FROM (select compound_id, name, ref_id, created, rank() OVER(Partition by compound_id order by case ref_id when 86 THEN 1 when 1 Then 2 when 3 THEN 3 WHEN 10 then 4 WHEN 17 THEN 5 WHEN 40 THEN 6 WHEN 43 THEN 7 WHEN 44 THEN 8 WHEN 45 THEN 9 ELSE 10 END) as rank 
From compound_labels where replace(name, ' ', '') NOT regexp '^D?B?C?(?:CHEMBL)?[0-9\-]+$') as c_grp where c_grp.rank = 1 GROUP BY c_grp.compound_id) as c_label join refs on c_label.ref_id= refs.id join compounds c on c.id = c_label.compound_id order by compound_id;

#Create v_genetic_events
CREATE VIEW v_genetic_events as 
select ge.id, gv.name as variant, g.name as gene, ge.endogenous_gene_position, ge.on_reverse_strand, ge.description, ge.injection_mix, u.username as user,
substring_index(ge.created, ' ', 1) as date_created, substring_index(ge.created, ' ', -1) as time_created
FROM genetic_events as ge LEFT OUTER JOIN genetic_variants as gv on ge.variant_id = gv.id LEFT OUTER JOIN genes as g on ge.endogenous_gene_id = g.id LEFT OUTER JOIN users as u on ge.user_id = u.id;

#Create v_wells
CREATE VIEW v_wells as 
select w.id, r.name as run, w.well_index, ct.name as control_type, gv.name as variant, w.well_group, w.age, substring_index(w.created, ' ', 1) as date_created, substring_index(w.created, ' ', -1) as time_created
FROM wells as w LEFT OUTER JOIN runs as r on w.run_id = r.id LEFT OUTER JOIN control_types as ct on w.control_type_id = ct.id LEFT OUTER JOIN genetic_variants as gv on w.variant_id = gv.id;

#Create v_find_tanks for all tanks based on most recent scan
CREATE VIEW v_find_tanks as
select ct.id, ct.internal_id as tank, gv.name as variant, mgv.name as mother_variant, fgv.name as father_variant, gv.id as variant_id, gv.mother_id as mother_id, gv.father_id as father_id, 
cp.name as project, cpt.name as project_type, ct.birthdate, ct.alive, cs.scan_value, cs.datetime_scanned as datetime_most_recent_scan, ct.notes
FROM carp_tanks as ct LEFT OUTER JOIN carp_projects as cp on ct.project_id = cp.id LEFT OUTER JOIN genetic_variants as gv on ct.variant_id = gv.id LEFT OUTER JOIN carp_tank_types as ctt on ct.tank_type_id = ctt.id 
LEFT OUTER JOIN carp_project_types as cpt on cpt.id = ctt.project_type_id LEFT OUTER JOIN genetic_variants as mgv on mgv.id = gv.mother_id LEFT OUTER JOIN genetic_variants as fgv on fgv.id = gv.father_id 
LEFT OUTER JOIN carp_scans as cs on cs.tank_id = ct.id
WHERE (cs.scan_type, date(datetime_scanned)) = (select scan_type, date(max(datetime_scanned)) as date_scanned from carp_scans where scan_type = "location");
