<?php
/**
 * @author Amin Mahmoudi (MasterkinG)
 * @copyright    Copyright (c) 2019 - 2021, MasterkinG32. (https://masterking32.com)
 * @link    https://masterking32.com
 * @Description : It's not masterking32 framework !
 **/

use Gregwar\Captcha\CaptchaBuilder;
use Medoo\Medoo;

class status
{
    public static function get_character_by_guid($realmID, $guid)
    {
        if (!empty($guid)) {
            $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level"), ["AND" => ["guid[=]" => $guid]]);
            if (!empty($datas[0]["level"])) {
                return $datas[0];
            }
        }
        return false;
    }

    public static function get_top_achievements($realmID)
    {
        $datas = database::$chars[$realmID]->query("SELECT guid, COUNT(*) as total FROM character_achievement GROUP BY guid ORDER BY total DESC LIMIT 10;")->fetchAll();
        if (!empty($datas[0]["guid"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_arenateams($realmID)
    {
        $datas = database::$chars[$realmID]->select("arena_team", array("arenaTeamId", "name", "captainGuid", "rating"), ['LIMIT' => 10, "ORDER" => ["rating" => "DESC"]]);
        if (!empty($datas[0]["arenaTeamId"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_killers($realmID)
    {
        $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level", "totalKills"), ['LIMIT' => 10, "ORDER" => ["totalKills" => "DESC"]]);
        if (!empty($datas[0]["totalKills"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_arenapoints($realmID)
    {
        $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level", "arenaPoints"), ['LIMIT' => 10, "ORDER" => ["arenaPoints" => "DESC"]]);
        if (!empty($datas[0]["arenaPoints"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_honorpoints($realmID)
    {
        if (get_config('expansion') >= 6) {
            $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level", "honorLevel", "honor"), ['LIMIT' => 10, "ORDER" => ["honorLevel" => "DESC", "honor" => "DESC"]]);
        } else {
            $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level", "totalHonorPoints"), ['LIMIT' => 10, "ORDER" => ["totalHonorPoints" => "DESC"]]);
        }

        if (!empty($datas[0]["level"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_playtime($realmID)
    {
        $datas = database::$chars[$realmID]->select("characters", array("name", "race", "class", "gender", "level", "totaltime"), ["ORDER" => ["totaltime" => "DESC"], 'LIMIT' => 10]);
        if (!empty($datas[0]["totaltime"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_gold($realmID)
    {
        $datas = database::$chars[$realmID]->select("characters", array("name", "level", "totaltime", "money"), ["ORDER" => ["money" => "DESC"], 'LIMIT' => 10]);
        if (!empty($datas[0]["money"])) {
            return $datas;
        }
        return false;
    }

    public static function get_top_guild_by_member($realmID)
    {
        $datas = database::$chars[$realmID]->query("SELECT guildid,name,leaderguid FROM guild WHERE guildid IN (SELECT guildid from guild_member GROUP by guildid ORDER by COUNT(*) DESC) LIMIT 10;")->fetchAll();
        if (!empty($datas[0]["name"])) {
            return $datas;
        }
        return false;
    }
}
