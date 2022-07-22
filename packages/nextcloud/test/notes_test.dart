import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage(apps: ['notes']);

  group('notes', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    test('Create note', () async {
      final response = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(
          NotesNote(
            title: 'a',
            content: 'b',
            category: 'c',
            favorite: true,
          ),
        ),
      ))!;
      expect(response.id, isPositive);
      expect(response.title, 'a');
      expect(response.content, 'b');
      expect(response.category, 'c');
      expect(response.favorite, true);
      expect(response.readonly, false);
      expect(response.etag, isNotNull);
      expect(response.modified, isNotNull);
    });

    test('List notes', () async {
      await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'a')),
      );
      await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'b')),
      );
      final response = (await validateResponse<List<NotesNote>, NotesNote>(
        client.notes,
        client.notes.getNotesWithHttpInfo(),
      ))!;
      expect(response, hasLength(2));
      expect(response[0].title, 'a');
      expect(response[1].title, 'b');
    });

    test('Get note', () async {
      final id = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'a')),
      ))!
          .id!;
      final response = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.getNoteWithHttpInfo(id),
      ))!;
      expect(response.title, 'a');
    });

    test('Update note', () async {
      final id = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'a')),
      ))!
          .id!;
      await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.updateNoteWithHttpInfo(
          id,
          NotesNote(
            id: id,
            title: 'b',
          ),
        ),
      );

      final response = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.getNoteWithHttpInfo(id),
      ))!;
      expect(response.title, 'b');
    });

    test('Update note fail changed on server', () async {
      final response = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'a')),
      ))!;

      await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.updateNoteWithHttpInfo(
          response.id!,
          NotesNote(
            id: response.id!,
            title: 'b',
          ),
          ifMatch: '"${response.etag}"',
        ),
      );

      expect(
        () => validateResponse<NotesNote, void>(
          client.notes,
          client.notes.updateNoteWithHttpInfo(
            response.id!,
            NotesNote(
              id: response.id!,
              title: 'c',
            ),
            ifMatch: '"${response.etag}"',
          ),
        ),
        throwsA(predicate((final e) => (e! as ApiException).code == 412)),
      );
    });

    test('Delete note', () async {
      final id = (await validateResponse<NotesNote, void>(
        client.notes,
        client.notes.createNoteWithHttpInfo(NotesNote(title: 'a')),
      ))!
          .id!;

      var response = (await validateResponse<List<NotesNote>, NotesNote>(
        client.notes,
        client.notes.getNotesWithHttpInfo(),
      ))!;
      expect(response, hasLength(1));

      await validateResponse<List<NotesNote>, NotesNote>(
        client.notes,
        client.notes.deleteNoteWithHttpInfo(id),
      );

      response = (await validateResponse<List<NotesNote>, NotesNote>(
        client.notes,
        client.notes.getNotesWithHttpInfo(),
      ))!;
      expect(response, hasLength(0));
    });

    test('Get settings', () async {
      final response = (await validateResponse<NotesSettings, void>(
        client.notes,
        client.notes.getSettingsWithHttpInfo(),
      ))!;
      expect(response.notesPath, 'Notes');
      expect(response.fileSuffix, '.txt');
      expect(response.noteMode, NotesSettingsNoteModeEnum.edit);
    });

    test('Set settings', () async {
      var response = (await validateResponse<NotesSettings, NotesSettings>(
        client.notes,
        client.notes.getSettingsWithHttpInfo(),
      ))!;

      response = (await validateResponse<NotesSettings, NotesSettings>(
        client.notes,
        client.notes.updateSettingsWithHttpInfo(
          NotesSettings(
            notesPath: 'Test Notes',
            fileSuffix: '.md',
            noteMode: NotesSettingsNoteModeEnum.preview,
          ),
        ),
      ))!;
      expect(response.notesPath, 'Test Notes');
      expect(response.fileSuffix, '.md');
      expect(response.noteMode, NotesSettingsNoteModeEnum.preview);

      response = (await validateResponse<NotesSettings, NotesSettings>(
        client.notes,
        client.notes.getSettingsWithHttpInfo(),
      ))!;
      expect(response.notesPath, 'Test Notes');
      expect(response.fileSuffix, '.md');
      expect(response.noteMode, NotesSettingsNoteModeEnum.preview);
    });
  });
}
