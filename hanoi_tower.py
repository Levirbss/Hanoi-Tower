def hanoi_solution(n_discs, origem = "A", auxiliar = "B", destino = "C"):
    if n_discs == 1:
        print(f"Mova disco 1 da Torre {origem} para a Torre {destino}")
    
    else:
        hanoi_solution(n_discs - 1, origem, destino, auxiliar)
        print(f"Mova disco {n_discs} da Torre {origem} para a Torre {destino}")
        hanoi_solution(n_discs - 1, auxiliar, origem, destino)

print('--------------\nTorre de Hanoi\n--------------')
discos = int(input('Digite o número de discos (com no máximo 2 algarismos):'))

print(f"Algoritmo da Torre de Hanoi com {discos} discos")

hanoi_solution(discos)

print("--------------\n   Concluido!\n--------------")
