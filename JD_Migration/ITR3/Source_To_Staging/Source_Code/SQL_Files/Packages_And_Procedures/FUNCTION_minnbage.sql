create or replace FUNCTION minnbage (
    zendcde     IN   VARCHAR2 DEFAULT ' ',
    prod_code   IN   VARCHAR2 DEFAULT ' ',
    pol_type    IN   VARCHAR2 DEFAULT ' ',
    ins_type    IN   VARCHAR2 DEFAULT ' '
) RETURN NUMBER AS
    v_minnbage NUMBER;
BEGIN
    CASE
        WHEN zendcde IN (
            'BSYCLCE',
            'BSCYCLE_PC'
        ) THEN
            v_minnbage := 0;
        WHEN zendcde = 'AMEX_CR' AND pol_type = 'P' THEN
            v_minnbage := 22;
        -- WHEN zendcde = 'AMEX_CR' AND pol_type = 'F' THEN
        WHEN  pol_type = 'F' THEN -- Min age will be always 0 for free plans
            v_minnbage := 0;
        WHEN ins_type = 'SPA' THEN
            v_minnbage := 65;
        WHEN zendcde = 'AMEX' AND prod_code IN (
            'FSP',
            'GSP',
            'LSP',
            'NCB',
            'SEP',
            'SSP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'AMEX2' AND prod_code = 'ART' THEN
            v_minnbage := 22;
        WHEN zendcde = 'ANA' AND prod_code IN (
            'NCP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'ASAHI-VISA' AND prod_code IN (
            'NCP',
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'CF' AND prod_code = 'FRP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'CHATEAU' AND prod_code IN (
            'HTA',
            'NCP',
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'DAIWA-VISA' AND prod_code IN (
            'HTA',
            'NCP',
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'DINERS' AND prod_code IN (
            'DGP',
            'FL1',
            'FL2',
            'FRP',
            'NRP',
            'TRP',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'DINOS-S' AND prod_code IN (
            'HTA',
            'NCP',
            'NCR',
            'POP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'FOBEL' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN ( zendcde = 'GC' AND prod_code = 'NCT' ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'HOKUSEN' AND prod_code = 'FL1' THEN
            v_minnbage := 22;
        WHEN zendcde = 'IDEMITSU' AND prod_code IN (
            'FRP',
            'MDP',
            'ML2',
            'ML3',
            'NCP',
            'NRP',
            'POP',
            'PP1',
            'RLP',
            'RPL',
            'SLP',
            'TRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'IEI' AND prod_code IN (
            'HTA',
            'NCP',
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'JAF' AND prod_code IN (
            'HTA',
            'JTA',
            'NCB',
            'RPD',
            'RPL'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'JCB' AND prod_code = 'NCR' THEN
            v_minnbage := 22;
        WHEN zendcde = 'JCB2' AND prod_code IN (
            'POP',
            'STA'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'KAMOME' AND prod_code IN (
            'KGP',
            'NCP',
            'POP',
            'SEP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'KC' AND prod_code IN (
            'FRP',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'KEIO' AND prod_code IN (
            'NCP',
            'NEF',
            'NEP',
            'POP',
            'RLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'KYOTSU' AND prod_code IN (
            'POP',
            'FRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'MAINICHI' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'MARUZEN' AND prod_code IN (
            'HTA',
            'NCP',
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'MC TSUSHO' AND prod_code IN (
            'LNG',
            'NCB',
            'RPL'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'MILLION' AND prod_code IN (
            'FL2',
            'FRP',
            'FTA',
            'HTA',
            'NCP',
            'POP',
            'RLP',
            'RTA',
            'SLP',
            'STA',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'MINATO' AND prod_code = 'FRP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'NICHIZEI' AND prod_code IN (
            'FAP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'NISSEN' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'NOMURA' AND prod_code IN (
            'FAP',
            'NCP',
            'POP',
            'SPP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'ORICO' AND prod_code IN (
            'NCB',
            'NCP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'RAKUTEN_C' AND prod_code IN (
            'FRP',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'SCCB' AND prod_code IN (
            'RPL',
            'RTP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'SEIBU' AND prod_code = 'NCP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'SHINNIHON' AND prod_code = 'RLP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'SHOP' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'SHUFU' AND prod_code IN (
            'NCP',
            'POP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'SOTSU' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'SOWA' AND prod_code = 'NCP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'SUMITOMO' AND prod_code IN (
            'HTA',
            'NCP',
            'NOP',
            'POP',
            'SLP',
            'STA',
            'ST1'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'SUNTORY' AND prod_code IN (
            'NCB',
            'NCP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'SURUGA' AND prod_code = 'FRP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'TOBU' AND prod_code IN (
            'FL2',
            'FRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'TOKYO-VISA' AND prod_code IN (
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'TOKYU' AND prod_code IN (
            'FL2',
            'HTA',
            'NCP',
            'POP',
            'RLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'TOP' AND prod_code = 'POP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'UCB' AND prod_code IN (
            'FL1',
            'FL2',
            'FRP',
            'NRP',
            'TMP',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'UFJ_JCB' AND prod_code IN (
            'FL2',
            'FRP',
            'ZRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'UNION' AND prod_code IN (
            'POP',
            'RLP',
            'SEP',
            'SLP',
            'SPP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'VISA-Jdpan' AND prod_code IN (
            'POP',
            'SLP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'YOUME' AND prod_code IN (
            'FL1'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'YOUME' AND prod_code IN (
            'FL2',
            'FRP'
        ) THEN
            v_minnbage := 22;
        WHEN zendcde = 'ZENIKYO' AND prod_code = 'WOP' THEN
            v_minnbage := 22;
        WHEN zendcde = 'ZENNICHI' AND prod_code = 'FL1' THEN
            v_minnbage := 22;
        WHEN zendcde = 'Jdrich' AND prod_code IN (
            'LCP',
            'NCP',
            'NCR',
            'NVC',
            'NVF',
            'POP',
            'RAP',
            'ROP',
            'RPL',
            'ZCP',
            'ZGM',
            'ZGO',
            'ZLP',
            'ZOP',
            'ZPL',
            'ZTA',
            'ZTP'
        ) THEN
            v_minnbage := 22;
        ELSE
            v_minnbage := 20;
    END CASE;

    RETURN v_minnbage;
END minnbage;
/
