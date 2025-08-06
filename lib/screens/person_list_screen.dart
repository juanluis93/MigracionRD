import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/person_provider.dart';
import '../models/person_model.dart';
import 'person_detail_screen.dart';

class PersonListScreen extends StatelessWidget {
  const PersonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.persons.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.users, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay registros',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Presiona + para agregar el primer registro',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadPersons,
          child: ListView.builder(
            itemCount: provider.persons.length,
            itemBuilder: (context, index) {
              final person = provider.persons[index];
              return PersonCard(person: person);
            },
          ),
        );
      },
    );
  }
}

class PersonCard extends StatelessWidget {
  final PersonModel person;

  const PersonCard({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const FaIcon(
            FontAwesomeIcons.user,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          person.nombre?.isNotEmpty == true ? person.nombre! : 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.edadEstimada != null)
              Text('Edad: ${person.edadEstimada} años'),
            if (person.nacionalidad?.isNotEmpty == true)
              Text('Nacionalidad: ${person.nacionalidad}'),
            Text('Fecha: ${dateFormat.format(person.fechaHora)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (person.fotoPath != null)
              const Icon(Icons.camera_alt, color: Colors.green, size: 16),
            if (person.audioPath != null)
              const Icon(Icons.mic, color: Colors.blue, size: 16),
            if (person.ubicacionGPS != null)
              const Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonDetailScreen(person: person),
            ),
          );
        },
      ),
    );
  }
}
