<?php

namespace App\Traits;

trait WmsSchema
{
    public function getTable()
    {
        $table = parent::getTable();
        
        // Si la tabla no tiene esquema, agregarlo
        if (!str_contains($table, '.')) {
            return 'wms.' . $table;
        }
        
        return $table;
    }
}
