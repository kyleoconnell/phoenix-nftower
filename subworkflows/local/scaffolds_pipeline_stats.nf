
include { GENERATE_PIPELINE_STATS      } from '../../modules/local/generate_pipeline_stats'
include { GENERATE_PIPELINE_STATS_EXQC } from '../../modules/local/generate_pipeline_stats_exqc'

workflow GENERATE_PIPELINE_STATS_WF {
    take:
        renamed_fastas
        filtered_fastas
        mlst
        gamma_hv
        gamma_ar
        gamma_pf
        quast_report
        busco
        wtasmbld_report        // channel: tuple (meta) path(report): KRAKEN2_WTASMBLD.out.report
        wtasmbld_krona_html    // channel: tuple (meta) path(krona_html): KRAKEN2_WTASMBLD.out.krona_html
        wtasmbld_k2_bh_summary // channel: tuple (meta) path(k2_bh_summary): KRAKEN2_WTASMBLD.out.k2_bh_summary
        taxa_id
        format_ani
        assembly_ratio
        amr_point_mutations    // channel: tuple val(meta), path(report): AMRFINDERPLUS_RUN.out.report
        gc_content             // CALCULATE_ASSEMBLY_RATIO.out.gc_content
        extended_qc            // true for internal phoenix and false otherwise

    main:
        ch_versions     = Channel.empty() // Used to collect the software versions

        if (extended_qc == true) {
            // Combining output based on id:meta.id to create pipeline stats file by sample -- is this verbose, ugly and annoying. yes, if anyone has a slicker way to do this we welcome the input. 
            pipeline_stats_ch = renamed_fastas.map{ meta, renamed_fastas         -> [[id:meta.id],renamed_fastas]},         by: [0])\
            .join(filtered_fastas.map{            meta, filtered_fastas        -> [[id:meta.id],filtered_fastas]},        by: [0])\
            .join(mlst.map{                       meta, mlst                   -> [[id:meta.id],mlst]},                   by: [0])\
            .join(gamma_hv.map{                   meta, gamma_hv               -> [[id:meta.id],gamma_hv]},               by: [0])\
            .join(gamma_ar.map{                   meta, gamma_ar               -> [[id:meta.id],gamma_ar]},               by: [0])\
            .join(gamma_pf.map{                   meta, gamma_pf               -> [[id:meta.id],gamma_pf]},               by: [0])\
            .join(quast_report.map{               meta, quast_report           -> [[id:meta.id],quast_report]},           by: [0])\
            .join(busco.map{                      meta, busco                  -> [[id:meta.id],busco]},                  by: [0])\
            .join(wtasmbld_krona_html.map{        meta, wtasmbld_krona_html    -> [[id:meta.id],wtasmbld_krona_html]},    by: [0])\
            .join(wtasmbld_report.map{            meta, wtasmbld_report        -> [[id:meta.id],wtasmbld_report]},        by: [0])\
            .join(wtasmbld_k2_bh_summary.map{     meta, wtasmbld_k2_bh_summary -> [[id:meta.id],wtasmbld_k2_bh_summary]}, by: [0])\
            .join(taxa_id.map{                    meta, taxa_id                -> [[id:meta.id],taxa_id]},                by: [0])\
            .join(format_ani.map{                 meta, format_ani             -> [[id:meta.id],format_ani]},             by: [0])\
            .join(assembly_ratio.map{             meta, assembly_ratio         -> [[id:meta.id],assembly_ratio]},         by: [0])\
            .join(amr_point_mutations.map{        meta, amr_point_mutations    -> [[id:meta.id],amr_point_mutations]},    by: [0])\
            .join(gc_content.map{                 meta, gc_content             -> [[id:meta.id],gc_content]},             by: [0])

            GENERATE_PIPELINE_STATS_EXQC (
                pipeline_stats_ch
            )

            pipeline_stats = GENERATE_PIPELINE_STATS_EXQC.out.pipeline_stats

        } else {
            // Combining output based on id:meta.id to create pipeline stats file by sample -- is this verbose, ugly and annoying. yes, if anyone has a slicker way to do this we welcome the input. 
            pipeline_stats_ch = renamed_fastas.map{ meta, renamed_fastas         -> [[id:meta.id],renamed_fastas]},         by: [0])\
            .join(filtered_fastas.map{            meta, filtered_fastas        -> [[id:meta.id],filtered_fastas]},        by: [0])\
            .join(mlst.map{                       meta, mlst                   -> [[id:meta.id],mlst]},                   by: [0])\
            .join(gamma_hv.map{                   meta, gamma_hv               -> [[id:meta.id],gamma_hv]},               by: [0])\
            .join(gamma_ar.map{                   meta, gamma_ar               -> [[id:meta.id],gamma_ar]},               by: [0])\
            .join(gamma_pf.map{                   meta, gamma_pf               -> [[id:meta.id],gamma_pf]},               by: [0])\
            .join(quast_report.map{               meta, quast_report           -> [[id:meta.id],quast_report]},           by: [0])\
            .join(wtasmbld_krona_html.map{        meta, wtasmbld_krona_html    -> [[id:meta.id],wtasmbld_krona_html]},    by: [0])\
            .join(wtasmbld_report.map{            meta, wtasmbld_report        -> [[id:meta.id],wtasmbld_report]},        by: [0])\
            .join(wtasmbld_k2_bh_summary.map{     meta, wtasmbld_k2_bh_summary -> [[id:meta.id],wtasmbld_k2_bh_summary]}, by: [0])\
            .join(taxa_id.map{                    meta, taxa_id                -> [[id:meta.id],taxa_id]},                by: [0])\
            .join(format_ani.map{                 meta, format_ani             -> [[id:meta.id],format_ani]},             by: [0])\
            .join(assembly_ratio.map{             meta, assembly_ratio         -> [[id:meta.id],assembly_ratio]},         by: [0])\
            .join(amr_point_mutations.map{        meta, amr_point_mutations    -> [[id:meta.id],amr_point_mutations]},    by: [0])\
            .join(gc_content.map{                 meta, gc_content             -> [[id:meta.id],gc_content]},             by: [0])

            GENERATE_PIPELINE_STATS (
                pipeline_stats_ch
            )

            pipeline_stats = GENERATE_PIPELINE_STATS.out.pipeline_stats
        }

    emit:
        pipeline_stats  = pipeline_stats
        versions        = ch_versions // channel: [ versions.yml ]
}
