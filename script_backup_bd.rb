#!/usr/bin/env ruby

=begin
    Script para realizar o dump de uma base de dados
    passando como parâmetros de linha comando
    a base, usuário, senha para conexão
    Versão: 0.0.1
=end

puts "Configurando banco para backup"

database = ARGV.shift
username = ARGV.shift
password = ARGV.shift
iterador_final = ARGV.shift

if iterador_final.nil?
    backup_file = database + Time.now.strftime("%Y%m%d")
else
    backup_file = database + iterador_final
end

puts "mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql"
puts "gzip #{backup_file}.sql"